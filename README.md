# izzy.sh

Source code for my website: https://izzy.sh

This site is currently hosted on netlify.

# Building

Building is done manually by executing `hugo`. I would add a nix package here, but it doesn't really make a lot of sense (it's a collection of HTML pages, come on). Also, trying to add a package in a nix flake is rather challening, as there is a circular dependency on itself. The footer of the website uses [Hugo's Git features](https://gohugo.io/variables/git/), which means that the flake would need an input on itself.

# Development

Just use `nix develop .#` to launch a development shell with hugo installed.