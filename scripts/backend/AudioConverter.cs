using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using FFMpegCore;
using Godot;

[GlobalClass]
public partial class AudioConverter : Node
{
	/*
		Code Taken from:
		u/farhil
		https://www.reddit.com/r/godot/comments/173q971/comment/k455bzu/
	*/
	static class AsyncHelper
	{
		private static readonly TaskFactory _myTaskFactory = new
		  TaskFactory(CancellationToken.None,
					  TaskCreationOptions.None,
					  TaskContinuationOptions.None,
					  TaskScheduler.Default);

		public static TResult RunSync<TResult>(Func<Task<TResult>> func)
		{
			return AsyncHelper._myTaskFactory
			  .StartNew<Task<TResult>>(func)
			  .Unwrap<TResult>()
			  .GetAwaiter()
			  .GetResult();
		}

		public static void RunSync(Func<Task> func)
		{
			AsyncHelper._myTaskFactory
			  .StartNew<Task>(func)
			  .Unwrap()
			  .GetAwaiter()
			  .GetResult();
		}
	}

	public static string APPDATA_PATH = System.Environment.GetFolderPath(System.Environment.SpecialFolder.ApplicationData); 

	public static AudioConverter Instance {get; private set;}
	public AudioStreamOggVorbis track;

	public override void _Ready()
	{
		Instance = this;
	}
  
	public AudioStreamOggVorbis ConvertAAC(string file)
	{
		//the program will freeze if we don't make it do the conversion in a different Thread
		Thread thread = new Thread(delegate ()
		{
			AsyncHelper.RunSync(() => Convert(file));
		});	

		thread.Priority = ThreadPriority.Highest;
		thread.Start();

		return track;
	}

	public async Task Convert(string file)
	{
		FFMpegArguments.FromFileInput(file).OutputToFile(APPDATA_PATH + "/Fruitcup Media Center/conv.ogg", true, 
		options => options
		.WithAudioCodec(FFMpegCore.Enums.AudioCodec.LibVorbis)
		.WithoutMetadata()
		.WithFastStart()).ProcessAsynchronously();

		track = AudioStreamOggVorbis.LoadFromFile(APPDATA_PATH + "/Fruitcup Media Center/conv.ogg");
		
	}

}
