using System;
using System.Linq;
using System.IO;
using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using TagLib;
using System.Reflection.Metadata.Ecma335;

[GlobalClass]
public partial class MusicGridDisplayHelper : Node
{

	const int MAX_SONG_TITLE_CHARS = 24;
	const int AUTO_GRADIENT_TITLE_CHARS = 4;
	const int MAX_SONGS_PER_COLUMN = 4;

	public static MusicGridDisplayHelper Instance {get; private set;}
	public override void _Ready()
	{
		Instance = this;
	}

	static public Dictionary<String, Array<String>> ReturnArtists(Array<String> files_to_load)
	{
		Dictionary<String,Array<String>> artist_files = new Dictionary<string, Array<string>>();

		foreach(string file in files_to_load)
		{
			Array<string> get_artists = (Array<string>)MetadataHandler.GetTag(file, "artist");
			
			foreach(string artist in get_artists)
			{
				if (!artist_files.ContainsKey(artist))
				{
					artist_files.Add(artist, []);
				}

				artist_files[artist].Add(file);

			}

		}

		return artist_files;
	}

	static public Dictionary<String, Array<String>> ReturnAlbum(Array<String> files_to_load)
	{
		Dictionary<String,Array<String>> album_files = new Dictionary<string, Array<string>>();

		foreach(string file in files_to_load)
		{
			string album = (string)MetadataHandler.GetTag(file, "album");

			if (!album_files.ContainsKey(album))
			{
				album_files.Add(album, []);
			}
			
			album_files[album].Add(file);

		}

		return album_files;
	}

    static public Button CreateButton(string file, Boolean use_metadata)
	{
		Button button = new Button();
		button.SetScript(GD.Load<Script>("res://scripts/class/wmc_button.gd"));

		string music_name = file.GetFile().GetBaseName();

		if (use_metadata) music_name = (string)MetadataHandler.GetTag(file, "title");

		button.Text = music_name;

		return button;
	}

}
