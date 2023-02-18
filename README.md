# mapMyDrives-CMD
Batch file to help your remove and add your favorite network drives to Windows.

Current Quirks and Features
===========================================
- Maps my personal network drives and prompts for SMB credentials. 
- UNC's are hard-coded in the script. 
- The 'Remove Mapping' function indiscriminately removes ANY AND ALL existing mapped drives.

Ideas for Future Quirks and Features
===========================================
1. Error handling for failed commands.
2. MY DRIVES: Ability to add/edit/manage/remove UNC's from lists of servers w. shares, and usernames plus if it's enabled for mapping. 
3. Store favorited UNCs in a flat file DB maybe? XML? JSON? CSV?
4. Windows doesn't allow multiple connections to a server using DIFFERENT usernames, enforce this. 
5. Parse existing mappings: Save/Restore existing mappings.
