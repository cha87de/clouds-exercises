# Lesson 2: Vertical Scaling

## Task: Stressing the Wiki

Now that we have a monitoring and our mediawiki running, it is time to put some load on mediawiki.

1. Run a stressing application from your computer (client) that queries the wiki. For this purpose you can use the apache benchmarking tool. After installing it (https://httpd.apache.org/docs/2.4/programs/ab.html), run two separate load tests; one without and one with concurrency. WARNING: before running the test, make sure you are pointing it to YOUR wiki installation.

    1. `ab -n 5000 http://PUBLIC-IP/wiki/index.php/Main_Page`
    2. `ab -c 10 -n 5000 http://PUBLIC-IP/wiki/index.php/Main_Page`

2. Explain what consequences the permanent querying has for your application. In particular, identify the (e.g. CPU, memory and network) load caused for your server via the Chronograf dashboard.

3. How many request/per second can your server handle in both test cases (output of ab)? How many requests on the apache and the database are shown in the Chronograf dashboard?

4. What do you think is the bottleneck of the current setup? The network? The apache webserver? The database? Use the Chronograf dashboard to find possible bottlenecks.

## Task: Vertical Scaling

Try to scale your application vertically, by adding more virtual hardware resources.

Before we create a new instance with more CPU and Memory, we should back up our work, by creating a new snapshot, e.g. named "mediawiki-snapshot-2" of your main_server.
Remove the first snapshot from exercise 1, since it has no monitoring installed.

To vertically scale your mediawiki setup, you can either use the "Resize Instance" option and change the flavour of the existing instance. Or you can recreate the instance from the snapshot. To resize, select the instance's menu, select "Resize Instance" and select the **new flavor medium**. Please note, that you have to confirm the resize action twice.

To recreate (e.g. if resize does not work), after the snapshot finished, delete your main_server instance with your mediawiki application, and launch a new instance. In the **source tab**, select in "Select Boot Source" the option "Instance Snapshot", and then pick **your snapshot**. Make sure to select "No" in "Create New Volume". Select **flavor medium**. If you need to attach a floating IP, Reassign the previously used one.

Next, validate that mediawiki and the monitoring data are still working properly.

Please note: the host attached to your public IP has now changed. When connecting via ssh, the host key verification will fail. You first have to remove the cached host key, which identified your old instance. On Linux, this can be done by editing the file `~/.ssh/known_hosts` or using `ssh-keygen -R YOUR_PUBLIC_IP`

## Question: Vertical Scaling

Repeat the steps for stressing the mediawiki. Compare the results of both benchmarks (without concurrency, with concurrency).

What differences can you see / not see? Can you explain them?
