# Video Restoration Batch Converter

A Bash script for batch converting and restoring old video files with quality enhancement filters and optional upscaling.

## Overview

This script processes multiple video files in a folder, applying professional-grade restoration filters including denoising, sharpening, and optional resolution upscaling. Perfect for digitizing and restoring old home videos from the early 2000s.

## Features

- **Batch processing**: Converts multiple videos automatically
- **Interactive menu**: Choose resolution option at runtime
- **Quality enhancement**: Applies denoising and sharpening filters
- **Optional upscaling**: Choose between original resolution, 720p, or 1080p
- **Modern codec**: Outputs to widely compatible H.264/MP4 format
- **Progress tracking**: Shows conversion progress (X of Y files)
- **Cancellable**: Press Ctrl+C at any time to stop the process
- **Multiple format support**: Handles .wmv, .avi, .mkv, .mov, .mpg files

## Dependencies

### Required

- **FFmpeg 7.0+**: The script uses FFmpeg for all video processing
  
  Install on macOS using Homebrew:
  ```bash
  brew install ffmpeg
  ```

  Verify installation:
  ```bash
  ffmpeg -version
  ```

### System Requirements

- macOS (tested on M4 MacBook Air, but works on any Mac with FFmpeg installed)
- Sufficient disk space (converted files may be larger than originals)

## Installation

1. Download or create the `convert_videos.sh` script
2. Make it executable:
   ```bash
   chmod +x convert_videos.sh
   ```

## Usage

### Basic Usage

Run the script in a folder containing video files:

```bash
./convert_videos.sh
```

The script will prompt you to select a resolution option:
```
=========================================
Video Restoration Batch Converter
=========================================

Please select resolution option:
  1) Keep original resolution (no upscaling)
  2) Upscale to 720p (1280x720)
  3) Upscale to 1080p (1920x1080)

Enter your choice (1-3): 
```

- **Option 1**: Keep original resolution (no upscaling)
- **Option 2**: Upscale to 720p (1280x720)
- **Option 3**: Upscale to 1080p (1920x1080)

**Cancelling the process:**

Press **Ctrl+C** at any time to cancel the conversion process. The script will show you:
- How many files were processed before cancellation
- Where your converted files are located
- Any files fully converted before cancellation will be usable

### Advanced Usage

Specify custom input and output folders:

```bash
./convert_videos.sh [input_folder] [output_folder]
```

**Examples:**

```bash
# Convert files in current directory to ./converted folder
./convert_videos.sh

# Convert files from a specific folder
./convert_videos.sh ~/Videos/Old ./converted

# Convert files from one folder to another location
./convert_videos.sh /Volumes/External/Videos ~/Desktop/Restored
```

## What the Script Does

### Video Processing Pipeline

1. **Denoising** (`hqdn3d=2:1:3:2`)
   - Reduces video noise common in old footage
   - Separate settings for brightness (luma) and color (chroma)

2. **Sharpening** (`unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1`)
   - Enhances edges and details
   - Uses a 7x7 matrix for optimal results

3. **Upscaling** (optional, `scale=1280:-2:flags=lanczos` or `scale=1920:-2:flags=lanczos`)
   - High-quality Lanczos scaling algorithm
   - Maintains aspect ratio automatically
   - Ensures dimensions are divisible by 2 (required for H.264)

4. **Color Format** (`format=yuv420p`)
   - Ensures maximum compatibility across all devices

### Encoding Settings

- **Video Codec**: H.264 (libx264)
- **Quality**: CRF 22 (excellent quality with reasonable file size)
- **Preset**: Slow (better compression efficiency)
- **Tune**: Film (optimized for film-like content)
- **Audio Codec**: AAC at 128 kbps
- **Fast Start**: Enabled for web streaming compatibility

## Supported Input Formats

- `.wmv` (Windows Media Video)
- `.avi` (Audio Video Interleave)
- `.mkv` (Matroska)
- `.mov` (QuickTime)
- `.mpg` (MPG)
- `.mpeg` (MPEG)

All files are converted to `.mp4` format.

## Output

### File Naming

- **Original resolution**: `filename.mp4`
- **720p upscale**: `filename_720p.mp4`
- **1080p upscale**: `filename_1080p.mp4`

### Output Location

By default, converted files are saved to a `./converted` folder in the current directory. This folder is created automatically if it doesn't exist.

## Expected File Sizes

Converted files may be **larger** than originals because:
- CRF 22 prioritizes quality over compression
- Old formats (.wmv) used aggressive compression
- Modern H.264 encoding preserves more detail

**Typical size comparison:**
- Original files (3 files): ~77 MB total
- Converted files: ~110-170 MB total (depending on CRF and upscaling)

To reduce file size, you can edit the script and change `crf 22` to `crf 24` or `crf 26`.

## Troubleshooting

### "Permission denied" error
Make sure the script is executable:
```bash
chmod +x convert_videos.sh
```

### FFmpeg not found
Install FFmpeg:
```bash
brew install ffmpeg
```

### Timestamp warnings during conversion
These are common with old video files and are automatically corrected. The output file will work properly.

### Video corruption warnings
Minor corruption in source files is normal for old footage. FFmpeg conceals these errors automatically.

### "height not divisible by 2" error
This has been fixed in the current version. The script now uses `-2` in the scale filter to ensure even dimensions, which is required for H.264 encoding.

### Cancelling mid-conversion
If you cancel with Ctrl+C:
- Completed files will be fully functional
- The file being processed when cancelled may be incomplete or corrupted
- You can safely delete incomplete files and re-run the script

## Performance Notes

- Conversion speed depends on file size and resolution
- M4 MacBook Air: Approximately 6-12x realtime speed
- The `preset slow` option prioritizes quality over speed
- All files are processed sequentially (one at a time)

## Customization

To modify the script's behavior, edit these settings in `convert_videos.sh`:

- **CRF value** (line ~85): Change `crf 22` to adjust quality (lower = better quality, larger files)
- **Audio bitrate** (line ~87): Change `b:a 128k` for different audio quality
- **Preset** (line ~84): Change `preset slow` to `fast` or `medium` for faster processing

## License

This script is provided as-is for personal use. FFmpeg is licensed under LGPL/GPL.

## Credits

Built for restoring old home videos with modern encoding standards and quality enhancement filters.
