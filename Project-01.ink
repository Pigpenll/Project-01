/*
    Project 01
    
    Requirements (for 15 base points)
    - Create an interactive fiction story with at least 8 knots 
    - Create at least one major choice that the player can make
    - Reflect that choice back to the player
    - Include at least one loop
    
    To get a full 20 points, expand upon the game in the following ways
    done [+2] Include more than eight passages
    done, instead of an inventory I have a class system[+1] Allow the player to pick up items and change the state of the game if certain items are in the inventory. Acknowledge if a player does or does not have a certain item
    done, there is a leveling system[+1] Give the player statistics, and allow them to upgrade once or twice. Gate certain options based on statistics (high or low. Maybe a weak person can only do things a strong person can't, and vice versa)
    done[+1] Keep track of visited passages and only display the description when visiting for the first time (or requested)
    
    Make sure to list the items you changed for points in the Readme.md. I cannot guess your intentions!

*/

/*
Dating sim
-takes course over several days
-can select outfits to meet "inventory" requirements
-love will be the statline
-probably only 1 suitor?
*/

/*
very short rpg
-intro
-class selection
-two fights maybe? that way i can implement stats being increased in between fights
*/

VAR class = 0 //0 = figher, 1 = rogue, 2 = wizard

-> begin

== begin ==
{Welcome. You are about to embark on an adventure.|Welcome back.}
Tell me, what suits you best?

+ [Fighter]
    ~ class = 0
    ->fighter
+ [Rogue]
    ~ class = 1
    ->rogue
+ [Wizard]
    ~ class = 2
    ->wizard
->DONE

=== fighter ===
Fighters use their brute strength to cut enemies down, diving straight into close-quarters battle.
You will begin with a sword.
Are you sure you want to be a Fighter?

+ [Yes.]
    ->intro
+ [On second thought...]
    ->begin
-> END

=== rogue ===
Rogues use their cunning intellect and stealth abilities to surprise and slay their foes.
You will begin with two daggers.
Are you sure you want to be a Rogue?

+ [Yes.]
    ->intro
+ [On second thought...]
    ->begin
-> END

=== wizard ===
Wizards use their expertise to cast devastating spells, capable of wiping out entire armies.
You will begin with a spellbook.
Are you sure you want to be a Wizard?

+ [Yes.]
    ->intro
+ [On second thought...]
    ->begin
-> END


== intro ==
So you've chosen {class == 0:Fighter|{class == 1:Rogue|Wizard}}.

+ [Continue.] ->exposition
->DONE


VAR pHealth = 20
VAR eHealth = 20
VAR level = 0
VAR potions = 0

//statuses
VAR ePoisoned = false

== exposition ==
A path lies ahead of you, winding into a dark forest.

+ [Begin journey.]
    ->wolfBattle
->DONE

== wolfBattle ==

{A wolf stands before you. It snarls. Its teeth are stained red with the blood of previous poor adventures.|The wolf stares at you, furious.}

What would you like to do?

HP: {pHealth}/20
Enemy HP: {eHealth}/20

+ {class == 0} Cleave
    {cleave()}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }
    
+ {class == 0} Slam
    ~ temp sdmg  = slam()
    {
        - sdmg > 0:
        {
            - eHealth > 0:
                The wolf takes {sdmg} damage!
            {
                - stagger():
                    The wolf is stunned!
                    ->wolfBattle
                
                - else:
                    The wolf staggers slightly, but remains upright.
                    ->wolfTurn
            }
            - else:
                The wolf takes {sdmg} damage!
                ->fin
        }
        
        - else:
            You attempted to slam into the wolf but missed!
            ->wolfTurn
    }
    
+ {class == 1} Backstab
    {backstab(0, 0)}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }
+ {class == 1} Poison Dart
    {poisonDart()}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }
+ {class == 2} Fireball
    {fireball()}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }
+ {class == 2} Restore
    {restore()}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }
+ Punch
    {punch()}
    {
        - eHealth > 0:
            ->wolfTurn
        
        - eHealth <= 0:
            ->fin
    }

->DONE

== wolfTurn ==
{~The wolf lunges at you, attempting to bite you.|The wolf swipes a large paw across your chest.|The wolf sprints towards you and bites at your leg.}

~ temp dmg = RANDOM(4, 6)
~ pHealth = pHealth - dmg
~ temp inflict = 0

You take {dmg} damage!

{
    - ePoisoned:
        ~ inflict = RANDOM(2, 3)
        ~ eHealth = eHealth - inflict
        The wolf is poisoned and takes {inflict} damage!
        {
            - RANDOM(1, 3) == 3:
                ~ ePoisoned = false
                The wolf recovered from the poison!
        }
}

{
    - pHealth > 0:
        ->wolfBattle
        
    - pHealth <= 0:
        ->death
}
->DONE


== function cleave ==
~ temp hit = RANDOM(1, 10)
~ temp crit = RANDOM(1, 10)
~ temp dmg = 0

{
    - hit <= 2:
        ~ dmg = 0
        ~ return "You swung and missed!"
    - else:
    {
        - crit == 10:
            ~ dmg = RANDOM(16, 24) + (level * 10)
            ~ eHealth = eHealth - dmg
            ~ return "Critical hit! You bring your sword down onto your foe, dealing a massive {dmg} damage!"
        - else:
            ~ dmg = RANDOM(8, 12) + (level * 5)
            ~ eHealth = eHealth - dmg
            ~ return "You bring your sword down onto your foe, dealing {dmg} damage!"
    }
}

== function slam ==
~ temp hit = RANDOM(1, 10)
~ temp dmg = 0

{
    - hit <= 3:
        ~ dmg = 0
        ~ return dmg
    - else:
        ~ dmg = RANDOM(4, 6) + (level * 5)
        ~ eHealth = eHealth - dmg
        ~ return dmg
}

== function backstab(tDmg, stabs) ==
~ temp hit = RANDOM(1, 10)
~ temp dmg = RANDOM(1, 4) + (level * 1)

{
    - hit > (10 - stabs):
        ~ dmg = 0
        ~ return "You hit {stabs} time(s) and dealt {tDmg} damage!"
    - else:
        ~ tDmg = tDmg + dmg
        ~ eHealth = eHealth - dmg
        ~ stabs++
        {backstab(tDmg, stabs)}
}

== function poisonDart ==
~ temp hit = RANDOM(1, 10)
~ temp dmg = RANDOM(1, 4) + (level * 4)

{
    - hit <= 2:
        ~ dmg = 0
        ~ return "You attempted to shoot a poison dart into your opponent but missed!"
    - else:
        ~ eHealth = eHealth - dmg
        ~ ePoisoned = true
        ~ return "You shot a poison dart into your opponent, dealing {dmg} damage and poisoning your opponent!"
}

== function fireball ==
~ temp hit = RANDOM(1, 10)
~ temp dmg = 0

{
    - hit <= 4:
        ~ dmg = 0
        ~ return "You hurled a fireball at your opponent but they dodged it!"
    - else:
        ~ dmg = RANDOM(12, 20) + (level * 10)
        ~ eHealth = eHealth - dmg
        ~ return "You throw a fireball at your opponent and it explodes, dealing {dmg} damage!"
}

== function restore ==
~ temp hp = RANDOM(3, 6) + (level * 4)
~ pHealth = pHealth + hp
{
    - pHealth > 20 + (level * 5):
        ~ pHealth = 20 + (level * 5)
}
~ return "You channel your healing powers, restoring {hp} health!"

== function punch ==
~ temp crit = RANDOM(1, 10)
~ temp dmg = 0

{
    - crit == 10:
        ~ dmg = RANDOM(6, 10) + (level * 6)
        ~ eHealth = eHealth - dmg
        ~ return "Critical hit! Your fist slams into the jaw of your foe, dealing a massive {dmg} damage!"
    - else:
        ~ dmg = RANDOM(3, 5) + (level * 3)
        ~ eHealth = eHealth - dmg
        ~ return "Your fist slams into the jaw of your foe, dealing {dmg} damage!"
}


== function stagger ==
{
    - RANDOM(1, 10) >= 4:
        ~ return true
    - else:
        ~ return false
}

== death ==
You have no remaining health! You have died!
->END

== fin ==
The wolf takes one more shuddering breath.

It falls over, dead.

+ [Continue]
    ->levelup
->END

== levelup ==
You leveled up!

You are now level 2. Your abilities deal more damage, and your maximum HP is raised to 25.

~ pHealth = 25
~ level = 1
~ eHealth = 50
~ ePoisoned = false

+ [Awesome!]
    ->chest
->DONE

== chest ==
You see a chest in the distance. Would you like to open it?

+ [Yes, open it.]
    {
        - RANDOM(1, 2) == 1:
            ->trap
        - else:
            ->reward
    }
+ [No, it's most likely a trap.]
    ->orcFight
->DONE

== trap ==
You swing the chest lid open.

Immediately, a puff of fungal particles sprays into your face. You look down and see the box is full of strange mushrooms. Your vision begins to blur...
+ [Uh oh...]
    ->unknown
->DONE

== unknown ==
You pass out onto the floor. Hopefully no hungry animals stumble across your body...
->END

== reward ==
You swing the chest lid open.

Two potion bottles full of a swirling red liquid sit in the chest. 

You found two Greater Health Potions!

~ potions = 2

+ [Pocket them!]
    ->orcFight
->DONE

== orcFight ==
{You continue along the path and eventually come across a cave entrance. A large orc stands guard.|}

{It lets out a deep bellow and raises its club.|The orc looms over you. You can smell its breath.}

What would you like to do?

HP: {pHealth}/25
Enemy HP: {eHealth}/50

+ {class == 0} Cleave
    {cleave()}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
    
+ {class == 0} Slam
    ~ temp sdmg  = slam()
    {
        - sdmg > 0:
        {
            - eHealth > 0:
                The orc takes {sdmg} damage!
            {
                - stagger():
                    The orc is stunned!
                    ->orcFight
                
                - else:
                    The orc staggers slightly, but remains upright.
                    ->orcTurn
            }
            - else:
                The orc takes {sdmg} damage!
                ->fin2
        }
        
        - else:
            You attempted to slam into the orc but missed!
            ->orcTurn
    }
    
+ {class == 1} Backstab
    {backstab(0, 0)}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
+ {class == 1} Poison Dart
    {poisonDart()}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
+ {class == 2} Fireball
    {fireball()}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
+ {class == 2} Restore
    {restore()}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
+ Punch
    {punch()}
    {
        - eHealth > 0:
            ->orcTurn
        
        - eHealth <= 0:
            ->fin2
    }
+ {potions > 0} [Drink a potion]
    You pop the cork off the bottle and chug the potion.
    You are restored to full health!
    ~ pHealth = 25
    ~ potions--
    ->orcTurn
    
    
->DONE

== orcTurn ==
{~The orc slams its club into you.|The orc kicks you with its massive foot.|The orc hurls a large rock at you.}

~ temp dmg = RANDOM(5, 12)
~ pHealth = pHealth - dmg
~ temp inflict = 0

You take {dmg} damage!

{
    - ePoisoned:
        ~ inflict = RANDOM(6, 7)
        ~ eHealth = eHealth - inflict
        The orc is poisoned and takes {inflict} damage!
        {
            - RANDOM(1, 3) == 3:
                ~ ePoisoned = false
                The orc recovered from the poison!
        }
}

{
    - pHealth > 0:
        ->orcFight
        
    - pHealth <= 0:
        ->death
}
->DONE

== fin2 ==
The orc falls with a large thud. 

+ [Finally.]
    -> gameEnd
->DONE

== gameEnd ==
You continue down the path, a battle worn adventurer.
->END
























