
### check autocommit

```mysql
select @@global.autocommit, @@session.autocommit;
```

```
+---------------------+----------------------+
| @@global.autocommit | @@session.autocommit |
+---------------------+----------------------+
|                   0 |                    0 |
+---------------------+----------------------+
1 row in set (0.00 sec)
```

* change autocommit

```sql
set autocommit = 0;
```

* my.cnf

```vi
[mysqld]
init_connect='SET autocommit=0'
```


### check tx_read_only

```sql
select @@global.tx_read_only, @@session.tx_read_only;
```

```
+-----------------------+------------------------+
| @@global.tx_read_only | @@session.tx_read_only |
+-----------------------+------------------------+
|                     0 |                      0 |
+-----------------------+------------------------+
```

* enable

```sql
set session transaction read only;
```

### referer

* MySQLのautocommitとトランザクション分離レベルのメモ
  * https://qiita.com/rubytomato@github/items/562a1638191aacaeb333
