===========================================================
CITRON EMULATOR: PORTABLE PGO TRAINING TOOLKIT
===========================================================

This toolkit allows you to create a version of Citron that is
specifically optimized for YOUR hardware (CPU). This is 
especially effective for Steam Deck users.

REQUIREMENTS:
- Approximately 6GB to 10GB of free space.
- An internet connection is NOT required to build.
- Works on SD Cards or Internal Storage.

STEP-BY-STEP INSTRUCTIONS:

1. EXTRACT: Extract this entire ZIP folder to your storage.
2. RUN STAGE 1: Open a terminal in this folder and run:
   bash Step1_Train.sh

   * This will compile Citron with "sensors" attached.
   * Once finished, Citron will launch automatically.
   
3. TRAIN: 
   * Open a game that is demanding or that you play often.
   * Play for at least 10-15 minutes. 
   * Visit different menus and areas.
   * Exit Citron normally (File -> Exit).

4. OPTIMIZE: Run the second script in your terminal:
   bash Step2_Finalize.sh

   * This script deletes the "training" code and rebuilds 
     Citron using the data gathered from your gameplay.
   * It will automatically package the result into an AppImage.

5. FINISH:
   * Your new, optimized AppImage will be in the 'dist' folder.
   * You can now move this AppImage anywhere and delete this 
     entire toolkit folder to save space.

NOTE FOR SHARING:
This build uses '-march=native'. If you build this on a Steam Deck,
it will work perfectly on all other Steam Decks. If you build it 
on a very new PC, it may not work on older PCs.
===========================================================
