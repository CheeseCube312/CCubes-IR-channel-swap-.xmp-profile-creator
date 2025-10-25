# XMP Profile Baker - Infrared Photography Tool

**Embed your custom DCP profile into XMP files for universal camera compatibility**

## Project Description

This project easily lets users create custom .xmp files to do one-click-channel-swaps and warps using Lightrooms "Profile" functionality.

## What you need

- This projects files
- your custom .dcp profile (for explanation, read furhter)
- Python not required: if missing portable version will be downloaded automatically

## How this works

This project includes my Universal .xmp files for channel swaps and channel warps, allowing for one-click-channel-swaps by using Lightroom Profiles as presets. They raw files are in source_xmp_files. The raw files don't just work for infrared photography with Adobe Lightroom since the programs white balance bottoms out at 2000k, leaving it unable to balance out the heavy red tint in most infrared photography. 

The common workaround are Infrared Profiles created using custom .dcp files that essentially remap the white-balance, extending it significantly. Since the channel swap profiles rely on that extended white-balance a pointer to said file needs to get "baked" into the .xmp file. Since .dcp files are camera specific I can't just create a universal .xmp profile.

That's what the included script is for. You provide a copy of your custom .dcp file and the script bakes its name into all the .xmp files. You can then copy+paste the output into the appropriate folder. That leaves you with the custom channel swap profiles.

## 📁 Folder Structure

```
XMP_Profile_Baker/
├── run_program.bat          # Click this to start the program
├── xmp_profile_baker.py     # Main program (GUI)
├── source_xmp_files/        # XMP files to process (included)
├── dcp_profile/            # Put your .dcp file here
└── output/                 # Processed files appear here
```

## Quick Start

0. **Create Custom DCP Profile for extended white balance**
   - You probably already did this for extending Lightrooms White balance
   - If not, just follow Rob Shea's tutorial https://www.youtube.com/watch?v=mWAmW5fGFsA

1. **Find Your DCP Profile**
   - Go to: `%APPDATA%\Adobe\CameraRaw\CameraProfiles\Imported`
   - Look for your infrared DCP profile (e.g., `Sony A7 II Infrared.dcp`)

2. **Copy DCP Profile**
   - Copy your `.dcp` file to the `dcp_profile/` folder

3. **Run the Program**
   - Double-click `run_portable.bat`
   - Follow the GUI instructions

4. **Get Your Files**
   - Processed XMP files will be in the `output/` folder

5. **Install in Lightroom**
   - Copy + Paste them into `%APPDATA%\Adobe\CameraRaw\Settings`
   - Restart Lightroom
   - Check under "Profiles" if they're installed

## Requirements

- **Windows** (tested on Windows 10/11)
- **Custom infrared DCP profile** (created for your camera)

## How It Works

1. **Input**: Universal XMP files + Your camera-specific DCP profile
2. **Check Requirements**: Can it find DCP profile? Auto-downloads portable python, if missing
2. **Processing**: Embeds DCP reference into XMP files
3. **Output**: Universal XMP files that work with your specific camera's extended white balance

## Included Profiles

The tool includes these infrared channel manipulation profiles:

### Channel Swap
- **Channel Swap G-B.xmp** - Swap Green and Blue channels
- **Channel Swap R-B.xmp** - Swap Red and Blue channels
- **Channel Swap R-G.xmp** - Swap Red and Green channels

### Channel Warp
- **Channel Warp B-G.xmp** - Blue to Green channel warp
- **Channel Warp B-R.xmp** - Blue to Red channel warp  
- **Channel Warp G-B.xmp** - Green to Blue channel warp
- **Channel Warp G-R.xmp** - Green to Red channel warp
- **Channel Warp R-B.xmp** - Red to Blue channel warp
- **Channel Warp R-G.xmp** - Red to Green channel warp

### Complex Transforms
- **Swap GB Warp RB.xmp** - Green↔Blue swap + Red→Blue warp
- **Swap GB Warp RG.xmp** - Green↔Blue swap + Red→Green warp
- **Swap RB Warp GB.xmp** - Red↔Blue swap + Green→Blue warp
- **Swap RB Warp GR.xmp** - Red↔Blue swap + Green→Red warp
- **Swap RG Warp BG.xmp** - Red↔Green swap + Blue→Green warp
- **Swap RG Warp BR.xmp** - Red↔Green swap + Blue→Red warp


## Troubleshooting

**"No DCP profile found"**
- Ensure your `.dcp` file is in the `dcp_profile/` folder
- Check that the file has a `.dcp` extension
- Click "Refresh" after copying the file

**"Python not found"**
- Install Python from [python.org](https://python.org)
- Make sure to check "Add Python to PATH" during installation

**"No XMP files found"**
- The source XMP files should be included
- If missing, re-download the tool

## License

MIT License - Free for personal and commercial use

## Support

For issues or questions, visit the project repository or create an issue.

---

**Created by Josef Brockamp using Copilot** | [github.com/CheeseCube312](https://github.com/CheeseCube312)
