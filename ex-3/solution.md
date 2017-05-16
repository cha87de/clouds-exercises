# Questions

## Lesson 1: Extend your knowledge about OpenStack

### Question: OpenStack Projects
1. How is the project called, which provides virtual machines in OpenStack?
2. What are the main differences between Object Store (Swift) and Block Storage (Cinder)?

### Question: Floating IPs vs. DHCP
What are the benefits and drawbacks of the manual assignment of floating IPs to virtual machines, compared to the automatic assignment in DHCP?


## Lesson 2: Multi-tier applications in Cloud Computing

### Question: Multi-tier applications

1. Which tiers are typically used in a web-based application?
2. How many tiers has the mediawiki application?
3. Why is it useful to deploy each tier to a separate vm in cloud computing? Or why is it not useful?


## Lesson 3: Horizontal Scaling and Load Balancing

### Question: Stressing the horizontally scaled mediawiki

- How much requests per second have you achieved with the vertically scaled mediawiki setup?
- How much requests per second do you achieve now with the horizontally scaled mediawiki setup?
- Vertical scaling was quite limited to the maximum flavor size. Can you image the new bottleneck of horizontal scaling?




# stressing the horizontally scaled system

Both mediawiki instances are running on flavor m1.small with 2 cpu cores.

```
ab -n 5000 http://134.60.47.195/wiki/index.php/Main_Page
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.47.195 (be patient)
Completed 500 requests
Completed 1000 requests
Completed 1500 requests
Completed 2000 requests
Completed 2500 requests
Completed 3000 requests
Completed 3500 requests
Completed 4000 requests
Completed 4500 requests
Completed 5000 requests
Finished 5000 requests


Server Software:        nginx/1.10.3
Server Hostname:        134.60.47.195
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13549 bytes

Concurrency Level:      1
Time taken for tests:   843.084 seconds
Complete requests:      5000
Failed requests:        4883                    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   (Connect: 0, Receive: 0, Length: 4883, Exceptions: 0)
Total transferred:      69855117 bytes
HTML transferred:       67740117 bytes
Requests per second:    5.93 [#/sec] (mean)     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Time per request:       168.617 [ms] (mean)
Time per request:       168.617 [ms] (mean, across all concurrent requests)
Transfer rate:          80.91 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.3      0      11
Processing:   150  168   9.9    166     284
Waiting:       73   89   9.2     87     184
Total:        150  169   9.9    167     285

Percentage of the requests served within a certain time (ms)
  50%    167
  66%    170
  75%    172
  80%    174
  90%    179
  95%    184
  98%    198
  99%    209
 100%    285 (longest request)


```

```
ab -c 10 -n 5000 http://134.60.47.195/wiki/index.php/Main_Page
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.47.195 (be patient)
Completed 500 requests
Completed 1000 requests
Completed 1500 requests
Completed 2000 requests
Completed 2500 requests
Completed 3000 requests
Completed 3500 requests
Completed 4000 requests
Completed 4500 requests
Completed 5000 requests
Finished 5000 requests


Server Software:        nginx/1.10.3
Server Hostname:        134.60.47.195
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13549 bytes

Concurrency Level:      10
Time taken for tests:   94.127 seconds
Complete requests:      5000
Failed requests:        920                      <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   (Connect: 0, Receive: 0, Length: 920, Exceptions: 0)
Total transferred:      69859080 bytes
HTML transferred:       67744080 bytes
Requests per second:    53.12 [#/sec] (mean)     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Time per request:       188.254 [ms] (mean)
Time per request:       18.825 [ms] (mean, across all concurrent requests)
Transfer rate:          724.78 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.3      0      13
Processing:    75  188  52.2    183     495
Waiting:       63  156  40.5    152     425
Total:         75  188  52.2    184     495

Percentage of the requests served within a certain time (ms)
  50%    184
  66%    207
  75%    222
  80%    232
  90%    258
  95%    278
  98%    306
  99%    321
 100%    495 (longest request)

```
