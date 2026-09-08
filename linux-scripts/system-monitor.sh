ram=$(free | awk 'NR==2{print $3}')

if [ $ram -gt 80 ]; then
    echo "Ram usage Warning"

else
    echo "Ram Usage Reasinable"
fi

disk=$(df -h | awk 'NR==2 {print $5}' | sed 's/%//')

if  [ $disk -gt 80 ]; then
     
      echo "Disk Percentage Low"

else  echo "Disk usage Reasonable"

fi

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)

if [ $cpu -gt 70 ]; then

   echo "Cpu Usage Warning"

else
    echo "Cpu Usage Reasonable"

fi
