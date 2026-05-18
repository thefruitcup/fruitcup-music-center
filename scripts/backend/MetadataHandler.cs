using System.Linq;
using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using TagLib;

[GlobalClass]
public partial class MetadataHandler : Node
{
	/*
		Gotta say, I had no idea C# in Godot was this limiting to be honest.
		Cross-Language Script Classes just don't work, so I can't use Resources
		I can't just call a C# Autoload Function in GDScript without having to do 
		MetadataHandler.call("GetMetadata",data)

		I can see why there aren't many tutorial or much info about this, it's extremely
		annoying and frustrating trying to get this working correctly.

		Also, note for myself:
		If another C# Autoload is added and it complains about it not inheriting a Node,
		You need to rename the file to be PascalCase instead of snake_case.
	*/

	public static MetadataHandler Instance {get; private set;}

	public override void _Ready()
	{
		Instance = this;
	}

	static public Dictionary<StringName, Godot.Variant> GetMetadata(StringName track)
	{
		Dictionary<StringName, Godot.Variant> metadata = new Dictionary<StringName, Godot.Variant>(); 

		var tfile = TagLib.File.Create(track);
		StringName title = tfile.Tag.Title;
		string[] u_artists = tfile.Tag.Artists;
		StringName album = tfile.Tag.Album;
		IPicture[] u_cover_art = tfile.Tag.Pictures;
		Array<StringName> artists = new Array<StringName>();
		Array<int> cover_art = new Array<int>();

		metadata["title"] = title;
		metadata["album"] = album;

		//i've got no idea if C# strings are converted into godot strings when needed
		foreach(string art in u_artists)
		{
			StringName c_artist = art;
			artists.Add(c_artist);
		}

		if(u_cover_art.Count() > 0)
		{
			//Note to self, Explicit Casts in C#
			//causes GDScript to shit itself and not recognize this as a class anymore
			//what is this frankenstein ass fucking engine bro
			Picture pic = new Picture();
			pic.Data = u_cover_art[0].Data;

			ByteVector data = pic.Data;
			Array<int> new_data = [.. data];

			cover_art.Resize(6553600);
			cover_art.Fill(0);

			for(int idx = 0; idx < new_data.Count();idx++)
			{
				cover_art[idx] = new_data[idx];
			}
		}

		metadata["artists"] = artists;
		metadata["art"] = cover_art;

		GD.Print("Aaaaa");

		return metadata;
	}
}
