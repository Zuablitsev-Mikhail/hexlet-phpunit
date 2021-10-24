# minimum reserved free disk space
reserved_free_space=2048

# FileSystem name pattern (as example like "/dev/sda1") You can find it by execute command "df -h"
disk_path_pattern='^/dev/sda1'

# file for logging status of execution backuping of logs
logrotate_log_path="/home/intexsoft/parfum/backup/backup_import_logs.log"

log_dir_pathes=('/home/intexsoft/parfum/app/src/var/import/stock/logs' '/home/intexsoft/parfum/app/src/var/import/order/logs' '/home/intexsoft/parfum/app/src/var/import/customer/logs' '/home/intexsoft/parfum/app/src/var/import/logs')

path_archive="/home/intexsoft/parfum/backup/logs/logs_import"

function create_directory_archive()
{
    for log_path in ${log_dir_pathes[@]};
    do

        local free_disk_space=$(get_free_disk_space)
        echo $free_disk_space
        echo $log_path
            if [ ! -d $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month') ];
            then
                logger_write_message "No such directory $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month')"
                continue
            else
                cd $log_path
                local name_dir=$(pwd|tr / "\n"|tail -2|head -1)
                echo $name_dir
                local dir_size=$(du -s --block-size=M $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month') | awk '{ print $1}' | cut -d'M' -f1)
                echo $dir_size
                if(($dir_size < $free_disk_space));
                then
                    logger_write_message "Start archiving directory $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month')"
                    tar -zcvf $path_archive/$name_dir-$(date +%Y-%m -d 'last month').tar.gz --directory=$log_path/$(date +%y -d 'last month') $(date +%m -d 'last month')
                        if [ $? -ne 0 ]
                                then
                                logger_write_message "An error occurred while archiving $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month')"
                                continue
                        else
                            logger_write_message "Deleting directory $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month')"
                            rm -rfv $log_path/$(date +%y -d 'last month')/$(date +%m -d 'last month')
                        fi
                    else
                        logger_write_message "Not enought free space  for backupping log directory: $log_path (Directory size: $dir_size(MB))"
                        continue
                    fi
            fi
        done
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

function logger_write_message()
{
    local date_formated=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$date_formated] $1" >> "$logrotate_log_path"
}

function delete_old_archive()
{
    logger_write_message "Searching and deleting old archive from $path_archive"
    find $path_archive/* -type f -mtime +365 -exec rm {} \;
}

delete_old_archive
create_directory_archive
logger_write_message "Backup logs Finished."

