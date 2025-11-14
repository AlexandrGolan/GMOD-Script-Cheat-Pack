-- [FILE NAME]: start_msg.lua
-- [STARTUP MESSAGE SCRIPT]

if CLIENT then
    hook.Add("InitPostEntity", "DisplayWelcomeMessage", function()
        timer.Simple(5, function()
            local blueColor = Color(30, 144, 255)
            
            -- [DISPLAY WELCOME MESSAGE IN CHAT]
            chat.AddText(blueColor, "                 |GMOD Script Cheat Pack|")
            chat.AddText(blueColor, "")
            chat.AddText(blueColor, "Hello, thank you for installing my cheat script collection.")
            chat.AddText(blueColor, "    If you enjoy playing with it, please subscribe")
            chat.AddText(blueColor, "    to my GitHub and give this repository a star.")
            chat.AddText(blueColor, "")
            chat.AddText(blueColor, "   https://github.com/AlexandrGolan/GMOD-Script-Cheat-Pack")
            chat.AddText(blueColor, "")
            chat.AddText(blueColor, "   This script pack")
            chat.AddText(blueColor, "     contains the following:")
            chat.AddText(blueColor, "")
            chat.AddText(blueColor, "     1.Aimbot")
            chat.AddText(blueColor, "     2.WallHack")
            chat.AddText(blueColor, "     3.Autowall")
            chat.AddText(blueColor, "     4.AutoBunnyHop")
            chat.AddText(blueColor, "")
            chat.AddText(blueColor, " P.S. I couldn't keep track of everything because I was mixing")
            chat.AddText(blueColor, " my code and the AI ​​code. There may be bugs or errors in the code,")
            chat.AddText(blueColor, " so please forgive me. I'm not learning Lua scripting for long.")
        end)
    end)
end