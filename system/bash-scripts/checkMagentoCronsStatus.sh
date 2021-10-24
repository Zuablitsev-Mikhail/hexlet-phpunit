#!/bin/bash

# Check the Magento cron jobs statuses
# Select cron jobs for last N minutes and
# check whether all the Magento cron jobs for last N minutes were executed with errors or missed
#

# email configuration
email_notification_enable=1
email_smtp='smtps://mail.intexsoft.by:465'
email_credentials='parfuemerie@intexsoft.by:na8MahD7voh0ciJ3'
email_sender='parfuemerie@intexsoft.by'
email_recipients=('parfuemerie@intexsoft.by')

# Current date
current_date=$(date +'%a, %-d %b %Y %H:%M:%S %z')

# DB configuration
database='magento2'
user='magento2'
password='e*Uwn3.S)21i'

# Docker DB container
docker_db_container='cebulla_db_1'

# Interval in minutes for checking last cron jobs
interval_in_minutes='15'

# Time duration
time_duration='1 HOUR'

# Time interval to treat cron jobs as suspended
suspended_crons_interval='2 HOUR'

# Error cron statuses
problem_cron_statuses=('error' 'missed')

# Condition to select cron jobs for last N minutes
last_crons_select_condition="select status from cron_schedule where scheduled_at > NOW() + INTERVAL $time_duration - INTERVAL $interval_in_minutes MINUTE"
last_cron_job_statuses=$(echo $last_crons_select_condition | docker exec -i $docker_db_container mysql -u$user -p$password $database)

# Condition to select cron jobs created for last N minutes
last_created_crons_select_condition="select status from cron_schedule where created_at > NOW() + INTERVAL $time_duration - INTERVAL $interval_in_minutes MINUTE LIMIT 1"
last_created_cron_jobs=$(echo $last_created_crons_select_condition | docker exec -i $docker_db_container mysql -u$user -p$password $database)

# Condition to select web site base url
site_base_url_condition="select value from core_config_data where path = 'web/secure/base_url' and scope = 'default'"

# Condition to select suspended cron jobs
suspended_cron_jobs_condition="select job_code, scheduled_at from cron_schedule where status = 'running' and scheduled_at > NOW() + INTERVAL $time_duration - INTERVAL $suspended_crons_interval"
suspended_cron_jobs=$(echo $suspended_cron_jobs_condition | docker exec -i $docker_db_container mysql -s -u$user -p$password $database)
echo $suspended_cron_jobs

# Get list of suspended cron jobs
function get_suspended_cron_jobs()
{
  for i in echo $suspended_cron_jobs
  do
    suspended_cron_jobs_array+=($i)
  done

  if [[ $suspended_cron_jobs -eq ' ' ]]
    then
       false
  fi

  if [[ ${#suspended_cron_jobs_array[@]} != 0 ]]
    then
       while IFS= read -r job
         do
           echo "$job"
         done < <(printf '%s\n' "$suspended_cron_jobs")
  fi
}

get_suspended_cron_jobs

# Get number of cron jobs for last N minutes
function get_last_cron_job_statuses_number()
{
  for i in echo $last_cron_job_statuses
  do
    last_cron_job_statuses_array+=($i)
  done
  echo ${#last_cron_job_statuses_array[@]}
}

# Get number of created cron jobs for last N minutes
function get_last_created_cron_job_number()
{
  for i in echo $last_created_cron_jobs
  do
    last_created_cron_jobs_array+=($i)
  done
  echo ${#last_created_cron_jobs_array[@]}
}

# Check the number of created cron jobs for last N minutes
function is_magento_cron_running()
{
  crons_number=$(get_last_created_cron_job_number)
  echo $crons_number
  if [[ $crons_number -eq 0 ]]
  then
    false
  else
    true
  fi
}

is_magento_cron_running

# Check whether all the Magento cron jobs for last N minutes were executed with errors or missed
function is_magento_cron_working()
{
  for cron_status in "${last_cron_job_statuses_array[@]}"
  do
    if [[ ${problem_cron_statuses[*]} =~ $cron_status ]]
      then
        wrong_statuses+=$cron_status
    fi
  done

  number_of_last_statuses=$(get_last_cron_job_statuses_number)
  number_of_wrong_statuses=${#wrong_statuses[@]}

  echo $number_of_last_statuses == $number_of_wrong_statuses

  if [[ $number_of_last_statuses == $number_of_wrong_statuses ]]
  then
    false
  else
    true
  fi
}

is_magento_cron_working

# Sending email notification
function send_mail_notification()
{
  # Site base url
  site_base_url=$(echo $site_base_url_condition | docker exec -i $docker_db_container mysql -s -u$user -p$password $database)

  # Directory to store email before sending
  temp_dir='/tmp'

  if (($email_notification_enable == 1));
  then
    local host_ip="$(curl ifconfig.me)"
    local emails=$(printf ", %s" "${email_recipients[@]}")
    emails=${emails:1}

    local recipients=$(printf " --mail-rcpt \"%s\"" "${email_recipients[@]}")

    # Trim base url
    trimmed_base_url="${site_base_url##*//}"
    trimmed_base_url="${trimmed_base_url::-1}"

    # Prepare the email
    echo "From: Server $host_ip ${trimmed_base_url} <$email_sender>" > $temp_dir/mail-to-send.txt
    echo "To: $emails" >> $temp_dir/mail-to-send.txt
    echo "Subject: Magento cron jobs are stopped" >> $temp_dir/mail-to-send.txt
    echo "Date: $current_date" >> $temp_dir/mail-to-send.txt
    echo "" >> $temp_dir/mail-to-send.txt
    echo "Alert from $site_base_url" >> $temp_dir/mail-to-send.txt
    echo "Magento cron jobs for last $interval_in_minutes minutes have been failed" >> $temp_dir/mail-to-send.txt

    #Send the email notification
    curl  --connect-timeout 15 --insecure "$email_smtp" -u "$email_credentials" --mail-from "$email_sender" $recipients -T $temp_dir/mail-to-send.txt --ssl
  fi
}

# Sending email notification
function send_mail_notification_about_suspended_cron_jobs()
{
  # Site base url
  site_base_url=$(echo $site_base_url_condition | docker exec -i $docker_db_container mysql -s -u$user -p$password $database)

  # Directory to store email before sending
  temp_dir='/tmp'

  if (($email_notification_enable == 1));
  then
    local host_ip="$(curl ifconfig.me)"
    local emails=$(printf ", %s" "${email_recipients[@]}")
    emails=${emails:1}

    local recipients=$(printf " --mail-rcpt \"%s\"" "${email_recipients[@]}")

    # Trim base url
    trimmed_base_url="${site_base_url##*//}"
    trimmed_base_url="${trimmed_base_url::-1}"

    list_of_suspended_cron_jobs=$(get_suspended_cron_jobs)

    # Prepare the email
    echo "From: Server $host_ip ${trimmed_base_url} <$email_sender>" > $temp_dir/mail-to-send.txt
    echo "To: $emails" >> $temp_dir/mail-to-send.txt
    echo "Subject: Some of magento cron jobs have been suspended" >> $temp_dir/mail-to-send.txt
    echo "Date: $current_date" >> $temp_dir/mail-to-send.txt
    echo "" >> $temp_dir/mail-to-send.txt
    echo "Alert from $site_base_url" >> $temp_dir/mail-to-send.txt
    echo "The following Magento cron job/jobs have been suspended:" >> $temp_dir/mail-to-send.txt
    echo "$list_of_suspended_cron_jobs" >> $temp_dir/mail-to-send.txt

    # Send the email notification
    curl  --connect-timeout 15 --insecure "$email_smtp" -u "$email_credentials" --mail-from "$email_sender" $recipients -T $temp_dir/mail-to-send.txt --ssl
  fi
}
# Send email if Magento cron jobs failed
if [[ ! $(is_magento_cron_working) || ! $(is_magento_cron_running) ]]
  then
    send_mail_notification
fi

# Send email if Magento has suspended crons
if [[ $(get_suspended_cron_jobs) ]]
  then
    send_mail_notification_about_suspended_cron_jobs
fi


