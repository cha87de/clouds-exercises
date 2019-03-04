# AB Benchmarks in bwCloud Scope


| CPU cores | Threads | Requests / s |
| --- | --- | --- |
| 1 | 1 | 23 Req/s |
| 1 | 10 | 28 Req/s |
| 2 | 1 | 25 Req/s |
| 2 | 10 | 60 Req/s |

## Scenario A1 (ab single thread, vertically scaled)

```
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.152.61 (be patient)
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


Server Software:        Apache/2.4.18
Server Hostname:        134.60.152.61
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13996 bytes

Concurrency Level:      1
Time taken for tests:   218.636 seconds
Complete requests:      5000
Failed requests:        23
   (Connect: 0, Receive: 0, Length: 23, Exceptions: 0)
Total transferred:      72839503 bytes
HTML transferred:       69980023 bytes
Requests per second:    22.87 [#/sec] (mean)
Time per request:       43.727 [ms] (mean)
Time per request:       43.727 [ms] (mean, across all concurrent requests)
Transfer rate:          325.35 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:    36   44   7.0     42     185
Waiting:       34   41   6.9     40     183
Total:         36   44   7.0     43     185

Percentage of the requests served within a certain time (ms)
  50%     43
  66%     43
  75%     44
  80%     45
  90%     47
  95%     50
  98%     56
  99%     65
 100%    185 (longest request)
```

## Scenario A2 (ab 10 threads, vertically scaled)

```
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.152.61 (be patient)
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


Server Software:        Apache/2.4.18
Server Hostname:        134.60.152.61
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13998 bytes

Concurrency Level:      10
Time taken for tests:   180.499 seconds
Complete requests:      5000
Failed requests:        4994
   (Connect: 0, Receive: 0, Length: 4994, Exceptions: 0)
Total transferred:      72707153 bytes
HTML transferred:       69985006 bytes
Requests per second:    27.70 [#/sec] (mean)
Time per request:       360.998 [ms] (mean)
Time per request:       36.100 [ms] (mean, across all concurrent requests)
Transfer rate:          393.37 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       1
Processing:   173  361  63.0    356    1794
Waiting:      166  328  61.4    324    1765
Total:        173  361  63.1    356    1795

Percentage of the requests served within a certain time (ms)
  50%    356
  66%    364
  75%    370
  80%    375
  90%    389
  95%    411
  98%    438
  99%    460
 100%   1795 (longest request)
```

## Scenario B1 (ab single thread, no vertical scaling)

```
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.152.61 (be patient)
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


Server Software:        Apache/2.4.18
Server Hostname:        134.60.152.61
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13996 bytes

Concurrency Level:      1
Time taken for tests:   197.344 seconds
Complete requests:      5000
Failed requests:        0
Total transferred:      72839327 bytes
HTML transferred:       69980000 bytes
Requests per second:    25.34 [#/sec] (mean)
Time per request:       39.469 [ms] (mean)
Time per request:       39.469 [ms] (mean, across all concurrent requests)
Transfer rate:          360.45 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:    32   39   2.8     39      90
Waiting:       30   37   2.7     37      87
Total:         32   39   2.8     39      90

Percentage of the requests served within a certain time (ms)
  50%     39
  66%     40
  75%     41
  80%     41
  90%     42
  95%     44
  98%     45
  99%     48
 100%     90 (longest request)
```

## Scenario B2 (ab 10 threads, no vertical scaling)

```
This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 134.60.152.61 (be patient)
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


Server Software:        Apache/2.4.18
Server Hostname:        134.60.152.61
Server Port:            80

Document Path:          /wiki/index.php/Main_Page
Document Length:        13996 bytes

Concurrency Level:      10
Time taken for tests:   82.707 seconds
Complete requests:      5000
Failed requests:        3774
   (Connect: 0, Receive: 0, Length: 3774, Exceptions: 0)
Total transferred:      72667147 bytes
HTML transferred:       69983774 bytes
Requests per second:    60.45 [#/sec] (mean)
Time per request:       165.415 [ms] (mean)
Time per request:       16.541 [ms] (mean, across all concurrent requests)
Transfer rate:          858.01 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0       5
Processing:    31  165  44.7    168     363
Waiting:       29  151  41.3    154     345
Total:         31  165  44.7    168     363

Percentage of the requests served within a certain time (ms)
  50%    168
  66%    185
  75%    197
  80%    204
  90%    221
  95%    235
  98%    251
  99%    261
 100%    363 (longest request)
```