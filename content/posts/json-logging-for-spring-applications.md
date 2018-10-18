---
title: "JSON logging for Spring applications"
date: 2018-08-02T08:00:00+02:00
tags: ["spring", "json"]
categories: ["blog"]
---

In this blog post we will discover how to enable _JSON_ logging for
your Springboot application.

Changing to a _JSON_ format in your file or console logs has many advantages. The most
mentioned one would be that _JSON_ log file are much easier to be searched and analyzed
when you are using tools such as the _ELK-Stack_. Especially when you use tools like `jq` 
_JSON_ formatted logs help you to figure out how you application behaves in real time.

I used the `logstash-logback-encoder` from [Logstash](https://www.elastic.co/de/products/logstash).
Just add it to your `pom.xml`.

```xml
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>5.1</version>
 </dependency>
```

Next you have to configure logback to use the new encoder. One option would be to simply
place a `logback-xml` configuration file in the application's classpath. For example in
`src/main/resources`.

I wanted to log the console in _JSON_ format, so i have created a new `ConsoleAppender`.

```xml
<configuration>
    <appender name="consoleAppender" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
    </appender>
    <logger name="jsonLogger" additivity="false" level="DEBUG">
        <appender-ref ref="consoleAppender"/>
    </logger>
    <root level="INFO">
        <appender-ref ref="consoleAppender"/>
    </root>
</configuration>
```

If you want to log in file, you could configure a `RollingFileAppender`.

```xml
<configuration>
    <property name="LOG_PATH" value="/tmp/json-log.json" />
    <appender name="jsonAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <File>${LOG_PATH}</File>
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <maxIndex>1</maxIndex>
            <fileNamePattern>${LOG_PATH}.%i</fileNamePattern>
        </rollingPolicy>
        <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <MaxFileSize>1MB</MaxFileSize>
        </triggeringPolicy>
    </appender>
    <logger name="jsonLogger" additivity="false" level="DEBUG">
        <appender-ref ref="jsonAppender"/>
    </logger>
    <root level="INFO">
        <appender-ref ref="jsonAppender"/>
    </root>
</configuration>
```

Till next time,
Chris