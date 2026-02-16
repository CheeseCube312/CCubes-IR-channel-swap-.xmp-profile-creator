# XMP Profile Baker - Infrared Photography Tool

**Easily create Infrared Channel Swap Profiles for Lightroom**

## Project Description

This project easily lets users create custom .xmp files to do one-click-channel-swaps and warps using Lightrooms "Profile" functionality.

## What you need

- This projects files
- a .dcp Profile that extends white-balance
- Lightroom Classic
- Python not required: if missing portable version will be downloaded automatically

## How this works

This project includes my own channel-swap Profiles. They allow for one-click channel swaps by using Lightroom Profiles thanks to their embedded LUT's. The raw files are in source_xmp_files. The raw files don't just work for infrared photography with Adobe Lightroom since the programs white balance bottoms out at 2000k, leaving it unable to balance out the heavy red tint in most IR photography. 

The common workaround are Infrared Profiles created using .dcp files that essentially remap the white-balance, extending it significantly. Since the channel swap profiles rely on that extended white-balance a pointer to said Profile needs to get "baked" into the .xmp file. That "Baking" is what this program is for.

There are 3 Options:
1. Rob Shea's Profiles: You installed his .dcp Profile pack. The Profiles are all labled the same.
2. Custom Profile, source name from your own Preset .xml-file
3. Manual input

Once done you can write the output into the ...\CameraRaw\Settings folder with one click.

## Folder Structure

```
XMP_Profile_Baker/
├── run_portable.bat         # Windows: Click this to start the program
├── run_portable.sh          # macOS/Linux: Double-click or run in terminal
├── xmp_profile_baker.py     # Main program (GUI)
├── source_xmp_files/        # XMP files to process (included)
├── output/                 # Processed files appear here
└── python_portable/         # Portable Python (auto-downloaded if needed)
```

## Key Features

- **Fully Portable**: No system installation required - everything contained in one folder
- **One-Click Setup**: Automatic Python download and setup on first run
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **Self-Contained**: No admin rights needed, no system pollution
- **Easy Cleanup**: Just delete the folder to remove everything

## Quick Start

0. **Install Rob Shea's .dcp Profile Pack or Create Custom DCP Profile for extended white balance**
   - You probably already did this for extending Lightrooms White balance
   - If not, just follow Rob Shea's tutorial https://www.youtube.com/watch?v=mWAmW5fGFsA
     or
   - Download his .dcp Pack here: https://www.robsheaphotography.com/infrared-profile-pack/

1. **Run the Program**
   - **Windows**: Double-click `run_portable.bat`
   - **macOS/Linux**: Double-click `run_portable.sh` (or run `./run_portable.sh` in terminal)
   - Select either:
     1. Rob Shea's Profiles
     2. Extract from .xmp file*
     3. Manual input
   - Click "Process Files"

2. **Get Your Files**
   - Processed XMP files will be in the `output/` folder
   - Click 

3. **Install in Lightroom**
   - use the "Write to Adobe Settings" button for automatic installation
   or
   - **Windows**: Copy files into `%APPDATA%\Adobe\CameraRaw\Settings`
   - **macOS**: Copy files into `~/Library/Application Support/Adobe/CameraRaw/Settings`
   - **Linux**: Copy files into `~/.adobe/CameraRaw/Settings`

   - Restart Lightroom
   - Check under "Profiles" if they're installed


*To grab a custom name from an .xml profile you need to export one first.
Open Lightroom, select your extended-WB-profile, Click '+' in "Presets", then "Create Preset". Set [x] tick at "Treatment & Profile", create preset.
You can now load that .xml into the program. The "Browse Files..." should open the correct folder by default

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

## License

MIT License - Free for personal and commercial use

## Support

For issues or questions, visit the project repository or create an issue.

---

**Created by Josef Brockamp using Copilot** | [github.com/CheeseCube312](https://github.com/CheeseCube312)
