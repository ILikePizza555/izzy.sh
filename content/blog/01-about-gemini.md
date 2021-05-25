---
title: "A simple design"
date: 2021-05-19T18:58:58-07:00
---

> Design is really a special case of problem solving. One wants to bring about a desired state of affairs. Occasionally one wants to remedy some fault but more usually one wants to bring about something new. For that reason design is more open ended than problem solving. It requires more creativity. It is not so much a matter of linking up a clearly defined objective with a clearly defined starting position (as in problem solving) but more a matter of starting out from a general position in the direction of a general objective.

Over-engineering is a problem I deal with on just about every project I work on.

Now, "over-engineering" is somewhat of a vauge term.
A "you'll know it when you see it" sort of term.
If you're an engineer reading this, you probably have more than your fair share of examples:
Thinking of some "incredibly important" feature that needs to be implemented right now while you're in the middle of working on your current goals, refactoring a whole section of code that does its job just fine because it could be more idiomatic, or using some giant complicated framework or a brand new language to solve a problem that just needs to be a python script.
It's applying too bit of a solution to a problem.

For me, over-engineering is like an "itch".
Some part of me identifies a problem, something like "this could be abstracted better" or "this feature could be parameterized more".
It's incredibly difficult for me not to scratch that itch.
Before long my "simple python script" has a requirements.txt and uses TOML config files.

When I have to design something myself this problem increases tenfold.

Design is an important part of engineering.
It's part of the engineering cycle where we disect and understand the problem to solve, and develop a plan to do so.
But it's also a very creative and open-ended process.
And if you don't pay close attention to problems requirements, its easy to design something way too big.

This is the issue I had while building this website

Now, what problem is being solved with a personal website or a blog?
It's simple: I want a place where I can put some text which will then be displayed in an easy-to-read format. A list of articles is available for navigation.
I also had a time limit -- a couple of days -- and I wanted my website to be fast.
There are a variety ways to solve this, ranging from social media to manually writing HTML/CSS files.
I want to own my own space, and I don't want to manutally write HTML everytime I want to make a post.
So, I settled for a middle route: using a static-site generator.

"Well, that's a pretty reasonable solution!", you might say.

And yes! It is! Until you realize that most static-site generators have some sort of theme engine.
This is a completely expected feature, but I personally prefer not to use someone else's theme.
I guess it's a matter of wanting a personal space to be personal to me. 
But this means that I have to design and write my own themes, and that's where it went off the rails.

My original idea for the design of this website involved a navbar along the top of page featuring a customizable list of links to various pages, a responsive design that would collapse the navigation into a side-out menu, a parallax background featuring a bunch of trees and hills, cover images for each article, a night mode switch, and even a switch that would let you change the font and text size of the post.
I basically scrolled through the Hugo theme showcase page and took every little idea that I thought was cool or would showcase my competence as an engineer.

Now, while this plan would solve my problem, it also does a whole lot more than just solve my problem. 
Something I always forget is that every little new feature I think about costs time.
Time in development.
Time in testing.
Time in maintenance.
There was no way this was going to get done in a couple of days.

Okay, I had to start again.
This time I needed some boundaries on my design. 
Some sort of limitation that would force me to slow down and think about what was really necessary.
I immediately thought of the Gemini project.

For those that don't know, Gemini is a minimalist hypertext transfer protocol.
And by "minimalist", I mean "people have written implementations in 50 lines of code in C" minimalist.
A request in the Gemini protocol consists of only a url.
A response body consists of the status code, the document's MIME type, and the document (if the status indicates a success).
The main reponse type of Gemini is "Gemtext" with a MIME of "text/gemini".
Gemtext allows you to format content by specifying separate line types, of which there are 7: text, links, preformatted, headings, unordered lists, and quotes.

When I first heard of Gemini, I hated it. 
It felt like a huge step back in computing.
Like a bunch of greybeards sat down and decided that modern computing was too easy to use.
That the ability to display content in a clean and user-friendly manner was somehow a bad thing.
Gemini was representative of the general desire in open-source spaces to return to a time where CLIs were the primary method of interacting with a computer.

Or so I said.

I guess I was stubborn and steadfast.
I saw the nearly complete lack of formatting and control over the content presentation and freaked out.
How was I supposed to make clean and nifty navigation menus with only one link on a line?
How was I supposed to make my content easy to read without `line-height` or the ability to customize the font-face and style?
How was I supposed to make something that was *good*?

It took the time pressure of needing to build a website in two days and having too much freedom to realize that while pictures and colors and formatting was nice and all, presentation doesn't make the content *good*.
I can certainly stylize the hell out of some Lorem ipsum and it would be fun to look at, but as an article it wouldn't be any *good*.
My problem only necessitates that my content is easy to look at, not pretty.

So I took Gemini's limitations, and I put them to my blog's theme.
One link per line, only unordered lists.
I took some artistic license with allowing myself a CSS file though.
I justify it by saying that's just how your theoritical client presents content.
Besides, your web browser probably has a reader-mode that will likely work perfectly on this blog, and you can adjust the font there.
I thought about serving my blog simultaneously on geminispace, and that would certainly be cool, but that's out of the project's scope. :)

When I took these limitation my plan was to start with the site navigation.
A list on the font page that would contain links to all the interesting pages.
I struggled with trying to make this look good within my limitation until I realized that I don't have anything interesting to navigate too just yet.
So, I don't have any need for a navigation menu.

The various other components I planned for my website followed the same path.
Up until I boiled it down to a single component that was strictly necessary:
A front page with a short introduction about myself, and a list of all the articles available to read.

I finished the website template in about two hours, and wow! It's quite a clean, modern look if I do say so myself.
