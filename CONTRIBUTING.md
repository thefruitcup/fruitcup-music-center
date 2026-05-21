# How to Contribute
First you'll need to download Godot Engine v4.6 No-UID Mono:<br>
https://github.com/carlosfruitcup/godot-no-uids

Then you'll need a Code Editor capable of editting C# Code (If you're sticking to GDScript, skip this step.)

Now Clone the project:<br>
```git clone https://github.com/thefruitcup/fruitcup-music-center.git```

Open Godot to the Project and once everything is done importing, you can get started.

*When writing code, please keep your variables, functions, etc. in snake_case when in GDScript (Exlcuding Class Names, please have them in CamelCase).<br>
Same applies when naming Nodes.*

**I will not accept Fully/Semi-Fully AI Generated Code.**
**Also, please use the No-UID Build provided, UIDs have caused consistent issues with classes failing to load and cluttering the filesystem.**
**PRs that include/use UIDs will not be accepted.**

# Pull Requests
Pull Requests such as Bug Fixing, Feature Additions/Improvements, Documentation/General Improvements, etc. are welcomed!<br>

Though Pull Requests removing/splitting scripts will require some explaination as for why.<br>
Pull Requests removing features will mostly not be accepted.<br>

When add/testing features & bug fixes, please consider performance, speed and consistency.<br>
Try to test with minimal tracks loaded (<100), multiple tracks loaded (100+) and a huge amount of tracks loaded (1000+).<br>

As well, when printing, please print with Console (Console.print_*) instead of Godot's print as it just makes it easier to debug without needing to see Godot. <br>
