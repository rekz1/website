---
title: "Prometheus in Spring Boot applications"
date: 2018-09-06T08:00:00+02:00
tags: ["spring", "prometheus", "springboot", "micrometer"]
categories: ["blog"]
---

In the last time people keep asking me how to enable [Prometheus](https://prometheus.io/) 
metrics in their [Spring Boot](https://spring.io/projects/spring-boot) applications. 

So today we will look at [Micrometer](https://micrometer.io/) and how to use it to make
various application metrics available in your actuator endpoint.

## Micrometer

Micrometer was introduced in Spring Boot 2's Actuator and works as the new application
metric collector.

There are many monitoring systems that are supported by Micrometer, like JMX, 
InfluxDB or Graphite, but our focus here lies on Prometheus.

So the first step is to add the Micrometer dependencies to your `pom.xml`.

```xml
<!-- Micrometer core dependency  -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-core</artifactId>
</dependency>
<!-- Micrometer Prometheus registry  -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

In addition you have to place following configuration in your `application.yml` to fully 
enable your new actuator endpoint. The new endpoint will be available at `/actuator/prometheus`.

```yaml
management:
  endpoint:
    prometheus:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
  endpoints:
    web:
      exposure:
        include: "*"
```

By default several `jvm` and `tomcat` metrics are available, like 
`jvm_threads_live` or `tomcat_sessions_active_max`. 

In addition i would recommend to implement several common tags, like application name. 

Following code adds for example for every exposed metric the application name as a tag.

```java
@Configuration
public class MeterRegistryConfiguration {

    @Bean
    public MeterRegistryCustomizer<MeterRegistry> meterRegistry(
            @Value("${spring.application.name}") String applicationName) {
        return registry -> registry.config()
                .commonTags("application", applicationName);
    }
}
```

### Bonus

When you are using Spring Boot and JPA and you are declaring a datasource, 
[HikariCP](https://github.com/brettwooldridge/HikariCP) is used since Spring Boot 2 as
the default connection pool.

When declaring a new `HikariConfiguration` bean you can set the injected `MeterRegistry`
to expose Hikari metrics as well.

```java
@Configuration
@RequiredArgsConstructor
public class HikariConfiguration {

    private final MeterRegistry meterRegistry;

    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")
    public HikariConfig hikariConfig(){
        final HikariConfig hikariConfig = new HikariConfig();
        hikariConfig.setMetricRegistry(meterRegistry);
        return hikariConfig;

    }
}
```

Till next time!

Chris