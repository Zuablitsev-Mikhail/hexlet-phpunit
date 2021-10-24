#!/bin/bash

# Calculation of the space required for the rotation of logs
# not start rotate logs and send emails, if free disk space is too low or start rotate logs
#

# minimum reserved free disk space
reserved_free_space=2048

# email configuration
email_notification_enable=1
email_smtp='smtps://mail.intexsoft.by:465'
email_credentials='a2b@intexsoft.by:a2b_pass1'
#email_credentials='parfuemerie@intexsoft.by:na8MahD7voh0ciJ3'
email_sender='parfuemerie@intexsoft.by'
email_recipients=('parfuemerie@intexsoft.by')

# pathes to dirs of log files
log_dir_pathes=('app/src/var/log' 'app/shared-files/logs/php' 'app/shared-files/logs/nginx')
# FileSystem name pattern (as example like "/dev/sda1") You can find it by execute command "df -h"
disk_path_pattern='^/dev/sda1'
# minimum file size to rotate
logrotate_min_file_size_to_rotate="50M"
# backuped files suffix
logrotate_date_suffix_format="%Y_%m_%d"
# file for logging status of execution backuping of logs
logrotate_log_path="backup/backup_logs.log"



current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

temp_dir=$current_dir/"app/src/var/tmpLogs"

function check_log_pathes()
{
    for log_path in ${log_dir_pathes[@]}
    do
        if [ -d "$current_dir/$log_path" ]; then
            log_pathes+=("$log_path")
            if [ ! -d "$current_dir/$log_path/backup/" ]; then
                mkdir $current_dir/$log_path/backup/
            fi
        fi
    done
}

function logger_write_message()
{
    local date_formated=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$date_formated] $1" >> "$current_dir/$logrotate_log_path"
}


function get_free_disk_space()
{
    local free_disk_space=$(echo $(df --block-size=M | grep -E $disk_path_pattern | awk '{ print $4}') | cut -d'M' -f1)
    if (($free_disk_space < $reserved_free_space));
        then
            echo 0
        else
            echo $(($free_disk_space - $reserved_free_space))
    fi

}

function get_used_disk_space_in_percent()
{
    echo $(df --block-size=M | grep -E $disk_path_pattern | awk '{ print $5}')
}

function send_mail_notification()
{
    if(($email_notification_enable == 1));
    then
        # local host_ip="$(/sbin/ifconfig | grep '255.255.255.' | awk '{print $2}')"
        local host_ip="$(curl ifconfig.me)"

        local emails=$(printf ", %s" "${email_recipients[@]}")
        emails=${emails:1}

        local recipients=$(printf " --mail-rcpt \"%s\"" "${email_recipients[@]}")

        echo "From: Server $host_ip <$email_sender>" > $temp_dir/mail-to-send.txt
        echo "To: $emails" >> $temp_dir/mail-to-send.txt
        echo "Subject: Alert: Almost out of disk space - $1 ($2M)" >> $temp_dir/mail-to-send.txt
        echo "Date: $(date)" >> $temp_dir/mail-to-send.txt
        echo "" >> $temp_dir/mail-to-send.txt

        echo "Not enought free space for backupping log files:" >> $temp_dir/mail-to-send.txt
        echo "" >> $temp_dir/mail-to-send.txt

            for email_body_notification in ${email_body_notifications[@]}
            do
                echo "$email_body_notification" >> $temp_dir/mail-to-send.txt
            done

        echo "" >> $temp_dir/mail-to-send.txt
        echo "Logs couldn't be rotated!!!" >> $temp_dir/mail-to-send.txt

        curl  --connect-timeout 15 --insecure "$email_smtp" -u "$email_credentials" --mail-from "$email_sender" $recipients -T $temp_dir/mail-to-send.txt --ssl
    fi
}

function backup_logs()
{
    local min_file_size_to_rotate=$(echo $logrotate_min_file_size_to_rotate | cut -d'M' -f1)
    local date_suffix="-"$(date +$logrotate_date_suffix_format)

    for log_path in "${log_pathes[@]}"
    do
        local current_log_dir="$current_dir/$log_path"
        local backup_log_dir="$current_dir/backup/logs/"


        for f in $current_log_dir/*.{log,access,error};
        do
            # logger_write_message "$f"

            if [ ! -f $f ]; then
            continue
            fi

            local file_size=$(du -s --block-size=M $f | awk '{ print $1}' | cut -d'M' -f1)
            local file_name=$(echo $f | rev | cut -d'/' -f1 | rev)
            local free_disk_space=$(get_free_disk_space)

            if(($file_size > $min_file_size_to_rotate));
                then
                    if(($file_size < $free_disk_space));
                     then
                        logger_write_message "Start copying file $current_log_dir/$file_name"
                        cp $current_log_dir/$file_name $backup_log_dir/$file_name$date_suffix
                        if [ $? -ne 0 ]
                            then
                                logger_write_message "There was an error in copy file $current_log_dir/$file_name"
                                exit
                            else
                                logger_write_message "Turncate $current_log_dir/$file_name"
                                echo "" > $current_log_dir/$file_name
                                logger_write_message "Start compressing file $current_log_dir/backup/$file_name$date_suffix"
                                gzip $backup_log_dir/$file_name$date_suffix
                        fi
                    else
                        logger_write_message "Not enought free space  for backupping log file: $current_log_dir/$file_name (file size: $file_size(MB))"
                        email_body_notifications+=("$current_log_dir/$file_name::$file_size(MB)")
                    fi
                else
                logger_write_message "No need to backup file: $current_log_dir/$file_name"
            fi
        done
    done
}


log_pathes=()
check_log_pathes

email_body_notifications=()
backup_logs

if [ $(echo ${email_body_notifications[@]} | wc -w) -ne 0 ]; then
    send_mail_notification "$(get_used_disk_space_in_percent)" "$(get_free_disk_space)"
fi

logger_write_message "Backup logs Finished."
