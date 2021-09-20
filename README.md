A modern jailbreak gamemode as attemp to revive dead gamemode in Garry's mod.
Initially developed in 2015, rewritten in 2019, finallized in 2021.

Current advantages:
* Flexible Q radial styled menu for simon with keyboard / mouse controls
* Fine support with most CS:S maps (like c4 replacement with basketball)
* Auto gameplay manager: anti-AFK, prevents passive gameplay, also don't give much time to disturb simon with attacks (i.e. you can run away from CTs, but you will be spotted if inactive)
* Anti wallhack addon inside
* Simple scoreboard inside
* Custom ingame gamemodes inside (fretta-like, but for round):
	- Free day (Just announce global freeday)
	- Point defense (Guards has time to take point and defend)
	- Hide & Seek (Prisioners become invincible for time and can't kill guards)
	- PvP (Global players vs player gamemode, enables by default if not enought players at both teams)
	- Team wars (Auto-split to 2-4 teams and fight against others)
	- Zombie freeday (A real zombie gamemode with simple implementation of waves)
* Some lr's but they're horrible:
	- last war (increase stats for last prisioner)
	- knife duel, random weapon duel, weapon roulette duel
	- take free day for the next round
	- "kill guards" (if guards can't kill prisioner within 5-15 seconds, they will die)
* 3 different types of simon points: point (max 4), line (max 2), circle (max 4)
* Simon can press buttons just hitting them
* Simon can paint lines on enviroment by holding "E" (+use) and after long press in single point it will create point 1
* Simon can change prisioner's abilities:
	- Bunny hop
	- Player collisions
	- Player avoidness (players will be pushed from another player's bounding box)
	- Prop damage (allow props to damage players)
	- Flashlights
	- Global voice chat (also for guards)
	- Single player voice chat (like gag, also for guards)
	- Ability to pickup props (like box, barrel)
* Simon also can:
	- count prisioners, that can see on his screen (+ throught visible valls)
	- spawn props, entities from pre-defined list (with limit, undo and auto-remove after dead)
	- respawn players once time per round
	- open any door from menu
	- set simon's deputy (if simon will be killed, system will automatically grant simon for alter player)
	- give / revoke free day to single prisioner
	- enable / disable boxing
	- delete points throught walls just seeing on them (no need to aim)
	- split prisioners to 2 - 4 teams and enable team boxing
	- open / close prisioner cells
* Simple gui for minimal jailbreak requirements
* Alternate F3 menu for simon
* Multiple languages support
* Multiple interfaces support
* Ability to take weapons from walls (css-like)
* Ability to replace weapons in hand to weapon that you're looking at
* Flexible death info like CS:S / CS:GO

Disadvantages:
* WIP
* API not completed
* Require much testing to complete gamemode
