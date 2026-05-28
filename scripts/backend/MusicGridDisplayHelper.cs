using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using TagLib;
using System.Linq;
using System.Reflection;

[GlobalClass]
public partial class MusicGridDisplayHelper : Node
{
	public static MusicGridDisplayHelper Instance {get; private set;}
	public int album_global_index = 0;
	public int artist_global_index = 0;

	public Godot.Timer artist_batch_timer;
	public Godot.Timer album_batch_timer;
	public Node global = null;

	public override void _Ready()
	{
		Instance = this;

		artist_batch_timer = new Godot.Timer();
		artist_batch_timer.WaitTime = 0.005;
		artist_batch_timer.Autostart = false;
		AddChild(artist_batch_timer);

		album_batch_timer = new Godot.Timer();
		album_batch_timer.WaitTime = 0.005;
		album_batch_timer.Autostart = false;
		AddChild(album_batch_timer);

		foreach(Node n in GetTree().Root.GetChildren())
		{
			if (n.Name != "Global") continue;

			global = n;
			break;
		}

		if (global == null)
		{
			GD.PrintErr("Something went horribly wrong, I was unable to find Global. Perhaps you're running an official build of Godot?");
			GetTree().Quit(125);
		}
	}

	public void ReturnArtistTask(Array<String> files_to_load)
	{
		/*
			I hated every moment coding this. This has been possibly the most miserable experience I've ever
			had coding, ANYTHING. The random crashes with no errors or warnings. The lack of C# Documentation
			for Godot ANYWHERE and the limitations of Cross-Language Scripting have made coding something
			simple as batching and adding artists and files to a Dictionary stored within a GDScript Autoload
			into a multi-hour nightmare. I never ever want to code something like this ever again.

			At least I didn't use AI.
		*/
		Dictionary<string, Array<String>> artist_files = (Dictionary<string, Array<string>>)global.Get("artists_files");


		for(int i = 0; i < 4; i++)
		{
			if(artist_global_index > files_to_load.Count() - 1) break;
			var file = files_to_load[artist_global_index];

			Array<string> get_artists = (Array<string>)MetadataHandler.GetTag(file, "artist");
			if (get_artists.Count() <= 0) get_artists.Append("Unknown Artist");
			
			foreach(string artist in get_artists)
			{
				if (!artist_files.ContainsKey(artist)) artist_files.Add(artist, []);

				artist_files[artist].Add(file);

			}

			artist_global_index++;
		}

	
		if(artist_global_index > files_to_load.Count() - 1) artist_batch_timer.Stop();
	}

	public void ReturnAlbumTask(Array<String> files_to_load)
	{
		Dictionary<string, Array<String>> album_files = (Dictionary<string, Array<string>>)global.Get("album_files");

		for(int i = 0; i < 16; i++)
		{
			if(album_global_index > files_to_load.Count() - 1) break;
			var file = files_to_load[album_global_index];
			
			string album = (string)MetadataHandler.GetTag(file, "album");
			if (album.Length <= 0) album = "Unknown Album";

			if (!album_files.ContainsKey(album)) album_files.Add(album, []);
			
			album_files[album].Add(file);

			album_global_index++;
		}	

		if(album_global_index > files_to_load.Count() - 1) album_batch_timer.Stop();

	}

	public void ReturnArtists(Array<String> files_to_load)
	{
		artist_global_index = 0;
		artist_batch_timer.Start();
		artist_batch_timer.Timeout += () => ReturnArtistTask(files_to_load);
	}

	public void ReturnAlbum(Array<String> files_to_load)
	{
		album_global_index = 0;
		album_batch_timer.Start();
		album_batch_timer.Timeout += () => ReturnAlbumTask(files_to_load);
	}

	static public Button CreateButton(string file, Boolean use_metadata)
	{
		Button button = new Button();
		button.SetScript(GD.Load<Script>("res://scripts/class/wmc_button.gd"));

		string music_name = "";

		if (use_metadata) music_name = (string)MetadataHandler.GetTag(file, "title");
		if (music_name.Length <= 0) music_name = file.GetFile().GetBaseName();

		button.Text = music_name;

		return button;
	}

}
