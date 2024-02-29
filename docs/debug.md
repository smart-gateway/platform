# Debug Procedures

## Facts

#### Checking a fact on the agent

```bash
facter -p <fact_name>
```

#### Testing fact code directly as ruby

```bash
ruby -e 'Dir.entries("/home").select { |entry| File.directory?(File.join("/home", entry)) && !(entry == "." || entry == "..") }'
```