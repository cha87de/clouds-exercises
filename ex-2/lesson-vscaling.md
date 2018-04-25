# Lesson 2: Vertical Scaling

## Task: Stressing the Wiki

Now that we have a monitoring and our mediawiki running, it is time to put some load on mediawiki.

1. Run a stressing application from your computer (client) that queries the wiki. For this purpose you can use the apache benchmarking tool. After installing it (https://httpd.apache.org/docs/2.4/programs/ab.html), run two separate load tests; one without and one with concurrency. WARNING: before running the test, make sure you are pointing it to YOUR wiki installation.

    1. `ab -n 5000 http://134.60.xy.yz/wiki/index.php/Main_Page/`
    2. `ab -c 10 -n 5000 http://134.60.xy.yz/wiki/index.php/Main_Page/`

2. Explain what consequences the permanent querying has for your application. In particular, identify the (e.g. CPU, memory and network) load caused for your server via the Chronograf dashboard.

3. How many request/per second can your server handle in both test cases (output of ab)? How many requests on the apache and the database are shown in the Chronograf dashboard?

4. What do you think is the bottleneck the current setup? The network? The apache webserver? The database? Use the Chronograf dashboard to find possible bottleneckts.

## Task: Vertical Scaling

Try to scale your application vertically, by adding more virtual hardware resources. In OpenStack in the Instances overview the option to "resize instance". Before we use this option to add more CPU and Memory, we should back up our work, by creating a new snapshot, e.g. named "mediawiki-snapshot-2". You can safely remove the first snapshot, since it has no monitoring installed. After the snapshot finished, resize your main_server instance with your mediawiki application to **flavor medium**. The resize process takes up to a few minutes and needs to be confirmed, don't miss this step on the dashboard.

Next, validate that mediawiki and the monitoring data are still working properly.

## Question: Vertical Scaling

Repeat the steps for stressing the mediawiki. Compare the results of both benchmarks (without concurrency, with concurrency).

What differences can you see / not see? Can you explain them?
