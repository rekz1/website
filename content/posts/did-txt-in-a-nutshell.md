---
title: "My did.txt file in a nutshell"
date: 2018-07-16T18:00:00+02:00
tags: ["linux", "terminal", "daily"]
categories: ["blog"]
---

This file represents a timestamped list of what i'm doing during the day.

Create an alias and add this to your `.bash_profile`. 

```bash
vim +'normal Go' +'r!date' ~/did.txt
```

I'm using [fish shell](https://fishshell.com/). 
So i created a new file in `~/.config/fish/functions/`, named it `did.fish` and added this.

```bash
function did
	vim +'normal Go' +'r!date' ~/did.txt
end
```

For me it is way more natural to read and type at the bottom of the file. So i added `normal Go` to move
the cursor at the end before reading from the `date` command.

#### Congrats!

You can now type `did` in your terminal to edit your very own did file!

```bash
Mo 16. Jul 18:00:00 CEST 2018
- wrote a blog post about my did file
```

Till next time,
Chris