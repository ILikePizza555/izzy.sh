---
title: "LunAI: Making a Multi-User ChatGPT as an April Fools Joke"
date: 2023-05-18T17:00:21-07:00
---

One day in a certain Discord server for software developers who were also fans of a particular show, an unexpected conversation unfolded in the moderation staff channel. See, the server owner jokingly suggested that we rename all of our channels to be ai-related somehow for April Fools. This prompted another staff member to jokingly suggest to announce that we were "experimenting with using GPT for automated moderation". 

I laughed at first, but then I started to wonder just how useful a moderation bot powered by a large language model (LLM) could be. LLMs excel at understanding context and sentiment, and they could interact with the community like any other user. Intrigued by the idea, I created a new Python project, marking the beginnings of LunAI, our AI-powered moderation bot.

## Prototype
In about two hours, I quickly threw together a prototype in python:
{{< figure src="LunAIv0.0.1-fs8.png" loading="lazy" alt="A screenshot of a Discord chat between myself and an early version of LunAI" caption="Transcript available [here](LunAIv0.0.1-transcript.txt)." >}}

For a few people this might be impressive, but all it really was was a program that connected the Discord and OpenAI APIs together. At this stage LunAI wasn't really much more than "multiplayer ChatGPT".

The most interesting aspect of the prototype was the per-channel sliding context window. This was an array of queues that retained the most recent messages for each channel LunAI got messages in. Then when a new message comes in, we give the channel's most recent messages to LLM to have it generate a response. This is much better than feeding *every* message to a singular context window, given the potential volume of messages in even a small discord server.

The main downside to this approach is that context is now compartmentalized to each individual channel. Each channel, thread, and DM is basically a "new instance" of LunAI. If a user does something in one channel, LunAI won't have any knowledge of it in any other channel. There are ways to work around this limitation, but I figured this feature was far out of scope for the project at this time.

I decided to show this prototype to the other staff members:  
{{< figure src="CloudSaysYes-fs8.png" loading="lazy" alt="A screenshot of a Discord chat between myself and 'Cloud Hop' agreeing to use LunAI for our April Fools event" caption="Transcript available [here](CloudSaysYes-transcript.txt).">}}

And so, I had a week to make fully-functional moderation bot.

## Planning features and implementations

As with just about every project I make, I almost immediately came up with a wealth of ideas for features and functionality that I could implement in my bot.

First and foremost, was for LunAI to have actual moderation capabilities. I figured the "joke" of an automated moderation bot would land a lot better if the bot actually had some teeth. Nothing too extreme though, just the ability to temporarily silence users, and escalate issues to the moderation staff. Escalation was simple enough, I just needed LunAI to ping the @Moderators role. Silencing users was a little more involved though. I figured what I could do was have the bot "run commands on itself". The model would output a command (like "!silence [user] [duration] [reason]") which would get send to the Discord channel. Then, this would be recieved by the program as any other message in the channel, where it would recognize the command and execute it like any other Discord bot. I later learned that this was called a [MRKL system](https://learnprompting.org/docs/advanced_applications/mrkl).

Second was the ability for LunAI to recognize users. This is a really important feature, but also a deceptively simple one. The issue here is security. If LunAI can perform moderation action, then it *has* to have the correct user 100% of the time. This can be a problem when users have modifyable usernames and discriminators, and when you're all but certain that someone is going to try to impersonate a moderator to gain special privileges with the bot. 

Third was the ability to "pin" messages to bot's context window. The idea was to assign certain messages a priority, and have the context window handle the priorities in such a way that lower-priority messages are cleared out before higher-priority ones. I intended this to be a debugging tool, to allow me to rapidly experiment with different instructions, but I figured it could also be a useful if the bot started misbehaving after deployment.

Fourth was the ability for LunAI to *not* respond to every message. My plan for this feature was to have three type of prompts: A decision prompt, a moderation prompt, and an interaction prompt. The decision prompt would determine what LunAI's next action would be, given the conversation: Do nothing, take moderation action, or interact in the conversation. Allowing the bot to *not* respond to every message would make it act much more like an ordinary user, and allow me to tailor prompts to a specific task, but the cost here would be API usage, which has actual monetary costs.

Fifth was the ability for LunAI to have some intristic knowledge. I wanted LunAI to recognize the moderation staff, and to know a few fun facts about itself and it's creator. There's no real purpose to this. I just thought it would be a fun "easter egg" and I like having my ego stroked. :)

In retrospect, I think all of these features were rather ambitious for this project, and in the end, I had to cut and scale back on a few things to hit the April 1st deadline. The multi-prompt system had to be cut completely. The bot did have the ability to perform moderation actions, but it was severely underpowered. Finally, the underlying system for the "pinning" feature was implemented, but the functionality was never exposed. I had to do all prompt adjustments by editing the code and restarting the bot.

## Development Challenges

For the sake of brevity, I won't be talking through the entire development process. Most of it was spent tweaking the system prompt usually by finding new ways to express my intentions in English (which I'm admittedly, not very good at). On top of that, my sleep issues started acting up during development week, and I was averaging about 4-5 hours of poor-quality sleep per night. However, I will be talking about some of the challenges I faced during development.

### Recognizing Users

As I mentioned previously, getting LunAI to distinguish between users was difficult. This was due to how the LLM interprets data in textual form. My first plan was to simply specify the format in the initial prompt and then provide every message to the LLM in that format, like so:  

```
You are LunAI, a moderation discord bot.
You receive messages in the format USERNAME ID: MESSAGE
Do not copy this format for your responses. Only output the message. Do not output the ID.
```

The LLM had a struggled a lot with understanding these instructions. Sometimes it would work, other times it would refer to me with my username and ID, other times it would prefix it's messages with "Luna:" or "Luna [String of numbers]" to match the format of messages it recieved. Even worse, if I provided it with user information in prompt, such as IDs of the moderators or myself, there was a good chance it wouldn't recognize me, or mistake another user with my name as me!

My username in Discord is "Queen Izzy", which as you can see has a space in it. So my first thought was that this was a simple case of having a bad format. I changed the format of messages to `USERNAME [ID]: MESSAGE`. This did improve it's ability to recognize users, but it still had a bad habit of outputting the ID when referring to users.

{{< figure src="LunaOutputtingIDs-fs8.png" loading="lazy" alt="A Discord screenshot showing LunAI referring to me with my name and my Discord user ID" caption="Transcript available [here](LunaOutputtingIDs-transcript.txt).">}}

At first I thought this was because LLMs struggle with large, opaque numbers, as they are often split up into several tokens. I wanted to experiment with using a system that could map user ids to simple words the LLM could easily understand, but I felt that experimenting with that solution would require more time than I had. 

Then I thought that maybe the issue was the LLM struggling to interpret the unusual format of messages. I really didn't want to do it, because it introduced a lot of token overhead for each message, but I experimented with providing the messages in a popular, self-describing data format: JSON.

Much to my surprise and exasperation, this was the "golden ticket" it seemed. It immediately and significantly improved consistency in regards to handling IDs across the board. 

### Mentioning Users

Another challenge I faced during development was mentioning users. This challenge arose from the intersection of Discord implementation of mentions and the general struggle LLMs have with numerics.

The way you mention a user in Discord through the API is by adding `<@id>` in your message body. There are also additional formats for mentioning a channel and a role. In early development LunAI struggled a lot with outputting the correct format for mentioning users. Sometimes it would simply write out "@Username", which obviously didn't work. I thought that maybe this was due to in inherent contradiction in my prompt. There was a rule to never output the id, but also a rule to construct mentions using the ID.

Switching my message format to JSON also improved performance in this area.

### Running commands

LunAI had access to two commands: A "silence" command to silence users, and a "clear cache" command that would clear the context window. To execute these commands, LunAI needed to output the command character (`$` which was later changed to `%` to improve performance), the command name, and the parameters of the command (if there were any). 

It was a challenge getting LunAI to execute these commands properly. The silence command was more complicated than the clear cache command, as it required parameters, one of which was user mention. The commands were also required to be outputted on their own separate line.

The LLM struggled heavily with this. It would often output the commands in markdown code blocks, which caused it to fail to execute.

{{< figure src="LunAISilenceFail-fs8.png" loading="lazy" caption="Transcript available [here](LunAISilenceFail-transcript.txt).">}}

LunAI also struggled with the clear cache command as well. Sometimes it would say that it "has executed the command" without actually executing it. Other times it would hallucinate the output of the clear cache command. And other times it would claim that it had no such functionality. Getting this to work consistently was a challenge.

{{< figure src="LunAIClearCache-fs8.png" loading="lazy" caption="Transcript available [here](LunAIClearCache-transcript.txt).">}}

I'm still not sure exactly why I couldn't get this to work consistently. Changing the command character and renaming the commands to words that would tokenized into a single token seemed to help improve consistency, but it still somewhat of a coin toss if LunAI would execute the commands properly or not.

### Being a moderator

Probably the most difficult challenge I faced was, well, alignment. 

LunAI was a terrible moderator. Not for the usual reasons one might suspect a bot is a terrible moderator. With the right instructions, it easily understood what was appropriate and what was not. The problem I had was the LunAI was extremely hesitant to take any action. You could threaten it, swear at it, insult it, or blatantly disregard its pleas for you to stop violating the rules, and it wouldn't actually do anything. Even worse, sometimes it would say "I'm going to silence you.", and then proceeded to not run the silence command.

{{< figure src="LunAIModerator-fs8.png" loading="lazy" caption="Transcript available [here](LunAIModerator-transcript.txt).">}}

It's hard to find a reason why this happened because it is fundamentally an alignment problem. I experimented with few-shot prompting by giving bot a few examples of when and how it should silence a user. This approach made it much more aggressive than I wanted, and it costed significantly more tokens that I wasn't really wseeing to spend.

## Launch Day

I think launch day will forever be fond memory for me. The night before, a friend of mine helped me deploy the bot to xer home-lab. I remember the activity and suspense in the moderation channel as we all geared up to make the changes to the Discord server at exactly 00:00 April 1st UTC. And I remember the heart-pounding anxiety I felt as I prepared to release LunAI to the world [^1].

I also remember adding the bot to the server and toggling on its speaking permissions. I watched as the first users discovered what I had just unleashed upon them. I watched as activity in the channel started to rapidly pick up, and LunAI started responding. I don't even remember what the topic was about because I just started laughing. For a good 15 minutes, I was just laughing so hard that I started crying and I couldn't read the messages in the channel.

Yeah, deployment was a bit dramatic, but hey. I'm an SDE II. We don't really get to deploy live services very often.

[^1]: Okay, well, it was a Discord server. A medium-sized Discord server, with maybe a hundred active users if we're being generous. But hey, all my friends were in there so it might as well have been my world.

## Response

I think the user base had a lot of fun with the bot. People immediately taunted the bot to try to get it to take some kind of moderation action against them. Surprisingly, LunAI did actually attempt to silence a few users. However, I messed up the Discord permissions, so the command failed.

I think the users were lulled into a false sense of security by this. Once they thought that the bot couldn't actually do anything against them, they started experimenting with more traditional AI things. Like changing the style of the responses. Or having it role-play.

{{< figure src="LunAIBackwards-fs8.png" loading="lazy" caption="Transcript available [here](LunAIBackwards-transcript.txt)." >}}

One thing I didn't account for at the time was their sheer volume of users who wanted to play with the shiny new toy. I put a 5 second slow mode on the channel in order to avoid overloading the bot, but even with that, the sheer number of people caused me to hit the OpenAI rate limits several times.

### Shortening Responses

{{< figure src="LunAIRateLimit-fs8.png" loading="lazy" caption="Transcript available [here](LunAIRateLimit-transcript.txt)." >}}

It soon became very clear that LunAI had some "quirks". It tended to be very ... wordy and overly apologetic. This was fine at first, but after just a few hours it got rather annoying. One of the users, however, discovered a really interesting way to get LunAI to shorten the length of its responses:

{{< figure src="kolmogorovcomplexity-fs8.png" loading="lazy" caption="Transcript available [here](kolmogorovcomplexity-transcript.txt)." >}}

As soon as I saw this, I to immediately added it to the prompt. This really improved the responses of LunAI, and even shortened its apologies!

### Interacting Like the Discord User Do

There were a few other interactions that I didn't consider during development. One of the more interesting ones invovled what I call "meaningless content". For example, people in Discord servers post all sorts text with no real meaning behind them. These can be inside jokes, emojis, random key smashes, and even just simple links to stuff.

When the LLM gets these messages it doesn't really understand that these messages don't have any meaning behind tinvolvedit gets confused and outputs yet another long-winded apology about how it's confused. This was especially bad and annoying in the memes channel (which was actually a thread in the channel that LunAI was restricted too, but threads in Discord are just Channels in the API).

To fix this, I simply added a clause to the prompt telling the AI that when it encounters meaningless content, to simply output a single emoji. This actually worked surprisingly well, and we ended up getting our memes channel back.

Later I added some more functionality to the program itself, which checked if the LLM's response 
was just an emoji. If it was, it added the emoji as a reaction to the original message, instead of sending a completely separate message.

## Learnings and Conclusion

{{< figure src="LunAIFinalLetter-fs8.png" loading="lazy" caption="Transcript available [here](LunAIFinalLetter-transcript.txt)." >}}

I had a lot of fun working on this project. This was one of the few personal projects I actually got to a "finished" state, and one of the fewer ones that actually got some kind of public use. I learned a lot about LLMs, their abilities, their quirks, their intricacies, and their limits. Overall, this whole event costed me about $40.

I think the biggest lesson I got from all this was that LLMs are really good at giving the illusion of thought and awareness, similar to how movies give the illusion of motion.

Going forward, I'd like to implement and experiment with some of the features I originally planned but had to cut for time. The multi-prompt decision-making feature still piques my curiosity. I'd also like to experiment with training or fine-tuning my own models. This might help me save a bit of money, but it would also let me really tune the alignment of the model for my needs. Also, it's just flat-out fascinating.

For anyone interested, feel free to follow-along with development here: <https://github.com/ILikePizza555/LunAI>

Until next time,
Izzy