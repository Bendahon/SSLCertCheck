# SSLCertCheck

Write the days remaining on SSL certs to a text file

If your local domain is *example* then you could do something like `cat /usr/local/ssl/*example*`

84

233

84

286

---

put the script in `/usr/local/bin/cert_exp`

Crontab could then do something like this
`0 0 * * * cert_exp 2>&1 | logger -t cert_exp`

# What can we do with that
Get it into Zabbix with an agent on the local PC
Name: ssl-www.example.com
vfs.file.contents[/usr/local/ssl/www.example.com.txt,UTF-8]

