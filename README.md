# Salsify Line Server

## Index
- [Summary](#summary)
- [System Design](#system-design)
- [Frameworks](#frameworks)
- [Installation](#installation)
- [Running](#running)

## Summary
This repository contains a server that returns a specific line of text based on its line index. It handles concurrent requests while maintaining low latency.

## System Design
### How does the system work
The server works by pre-processing a text storing the byte offset for each line in an array; this array is composed of the byte offset for the first character of the line, which is stored as an index, and the value corresponds to the byte in the text file. 

```
text = "This is a test file\n
This is the second line\n
This is the third line\n
This is the fourth line"

byte_offsets = [0, 20, 44, 68]
```

Pre-processing the file ensures that the server is memory efficient, as the text file is not loaded in memory, only its byte offset; this keeps the RAM usage low, even for large files; it jumps directly to the line requested, which eliminates the need to read the file sequentially for each request. 
As the system reads each line at the byte level, it is fast enough to handle concurrent requests without a significant increase in latency.

The API is built using Sinatra, which wraps the pre-processor with one endpoint, calling the preprocessor to retrieve the line requested; this layer also handles indexes out of range and other potential errors.

Another feature of the system is the multi-threaded capability of the server, built with Puma - it ensures that multiple users can request lines concurrently without affecting peformance; file operations by design are fast and independent, so multiple threads can read different parts of the file.

### How does the system performs with large files
#### 1GB file
Pre-processing a file this size should take less than a minute, if the average line length is 100 bytes; around 80mb of memory would be needed for such an offset array (10 million lines, give or take). Once is pre-processed, line retrieval is lightning fast, as the server only needs to read the requested line.
#### 10GB file
Only the pre-processing layer would take longer here, which would take several minutes; this could be a bottleneck, so pre-processing the file in batches could be a workaround. Memory usage would spike to 800mb, which is still manageable; concurrent requests would still be very good, as the server would only need to read the requested line.
#### 100GB file
A file this size would take tens of minutes to be pre-processed, and memory would spike to at least 8gb; such a file would have to be processed in chunks, potentially in parallel, to avoid memory issues. Handling concurrent requests would depend on resources available.

### How does the system handle concurrent requests
#### 100 users
Even with simultaneous requests, the server should be able to handle it effortlessly, and performance would still be very good; pre-processing step happens at initialization, and a default configuration for puma (16 threads per worker) should be enough to handle this load. File access would be rather fast, and no bottlenecks are expected with this amount of users - IO may spike, but it's manageable with a SSD.
#### 10000 users
This amount of users would put strain on the server if requests are made at the same time; scaling Puma horizontally (adding more workers) would solve the issue, coupled with a load balancer (Nginx) to distribute traffic across instances; some vertical scaling might also be needed to keep latency times low. SSDs are paramount here as there'll be a higher load on disk; RAM memory would also be have to be increased for the larger thread pool.
Some caching(Redis) may be needed for all users simultaneously requesting the same line, to avoid reading the file multiple times.
#### 1000000 users
At this level, the server would crash; for simultaneous requests, the server would need to be agrresively scaled, with multiple instances running behind a load balancer; an extreme increase in thread pool and a Redis cache would be needed to avoid reading the file multiple times; a database could also be used to store the pre-processed data, to avoid re-processing the file every time the server restarts.

## Documentaiton
- [How to start Sinatra app using Puma](https://www.lounge.se/SinatraRackPuma) - general configuration around puma and sinatra
- [Sinatra Documentation](http://sinatrarb.com/intro.html) - documentation for Sinatra, APIs and default patterns
- [Tutorial: Run a Sinatra application](https://www.jetbrains.com/help/ruby/sinatra.html) - tutorial on how to run Sinatra applications
- [How to Use Sinatra to Build a Ruby Application](https://blog.appsignal.com/2023/05/31/how-to-use-sinatra-to-build-a-ruby-application.html) - tutorial on how to build a Ruby application using Sinatra
- [Multi-Threading in Ruby](https://wesleydavis.medium.com/multi-threading-in-ruby-1c075f4c7410)Ruby and its multi-threaded capabilities

## Frameworks
- [Ruby](https://www.ruby-lang.org/)
- [Sinatra](http://sinatrarb.com/)
- [Puma](https://puma.io/)
- [Rspec](https://rspec.info/)
- [Rubocop](https://rubocop.org/)
- [pry](https://pry.github.io/)

Ruby was chosen for my familiarity with it, as I work with the language on a daily basis, and I'm used to its powerful syntax and simplicity.

Sinatra, on the other hand, is a framework that I had never used before, as I generally work with Rails; I chose it because it's lightweight and easy to use, and it's perfect for this kind of project, where a full-fledged framework like Rails would be overkill; I see Sinatra as Ruby's Flask(Python).

RSpec, Rubocop & pry are tools that I use on my-day-to-day work, and I'm very familiar with them; they're part of my workflow, and their aliases on my terminal are muscle memory by now.

Puma is also a library that I wanted familiarity with, as I usually work with Unicorn; I chose it to learn more about it, and because of the amount of documentation available.

### Time spent
Although writing the system took relatively little time, the research and documentation took a considerable amount of hours; doing so while working full time might've hampered the speed at which I finished the project; overall, the time invested was around 10-12 hours.
If I had unlimited to spend on this, what'd be looking at cloud infrastructure, horizontal scaling, and more in-depth testing - specially around stress testing the system. Priorities would be have an infra-structure capable of scaling gracefully, keeping cloud costs at a minimum.

## Code Critique
This is a simple project, and the code is a reflection of it - this is specifically why I've used Sinatra, for its ease of use. Even though it is simple, it's well-organised and test coverage is good enough; it uses a simple design pattern, and it's easy to understand and maintain. 

## Installation
Clone the repository and run the following commands:
```
bash build.sh
```

This will install the necessary gems and start the server.

## Running
To start the server, run the following command:
```
bash run.sh
```