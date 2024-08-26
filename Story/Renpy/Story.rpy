#Declare characters used by this game. Keep editing this section as the game goes on to add more characters.
define c = Character(_("Cynthia"), color="#c8ffc8")
define m = Character(_("Matthew"), color="#cc0000" )
define a = Character(_("Alex"), color="#81eff3")
define w = Character(_("Witch"), color="#c500cc" )
define kon = Character(_("Knights of the Knight"), color="#1b0370")
define po = Character(_("Police Office"), color="#0e860a")

#The game starts here.
label start:
#Prologue

#This shows a black screen with the text Prologue
    scene black with dissolve
    show text "BOOKNAME\nPrologue" with Pause(1.5) with fade
    show text "London was being attacked by a witch in 1855" with Pause(2.5) with fade
    show text "Every day the people of london were terrified if that day would be their last..." with Pause(3) with fade
    scene black with dissolve
#This shows London in 1855
    scene bg london1855withfireballs with dissolve

    "Fireballs and lightning rain down from the sky"
    
    show KnightsofNight
    "The Knights of the Night formed to fight the witch and save London, led by Alexander Frost." 
    
    scene witchlairoutside with fade

    "Fifteen brave men went to the witch's lair--a dark, damp cave deep in the forest--armed with their revolvers and swords."

    scene witchlairinside
    "The Knights were afraid, but they were determined to save London."
    "The thoughts of their friends and families in danger from the witch kept them going."
    "But, the witch somehow knew that the Knights were coming."
    "The Knights walked further into the cave and heard a click."
    "The Kngihts quickly dropped to the ground, except for the five slowest Knights."
    "They were impaled by wooden stakes that sprang from the wall, wailing from the pain, they slowly died."

    show KnightsofNight at left
    "The Knights found the witch and she charged at them!"

    show Witch at right with moveinright
    "The Witch started throwing fireballs and lightning at the Knights while they started firing their revolvers at her and readying their swords!"
    "It was a massacre."
    "Only Alex remained and with his friends' death weighting heavily on his heart, he beat the odds and caught the Witch."
    "Alex drove his sword trough the witch's heat, but with her dying breath, she cursed him."

    w "You will live forever with the hunger for human blood. You will be a monster"

    scene bg london1855 with fade
    "For the next few days, everything was beginning to go back to normal."
    "London was being repaired, people were living their lives, and there was no threat from any more attacks."
    "Alex was enjoying spending time with his wife and kids after being away from them for so long searching for the witch. He missed his simple life as a blacksmith."
    scene black with dissolve
    "Two Weeks Later"
    scene bg london1855 with fade
    "Alex ended up forgetting about the curse that the Witch inflicted upon him, until he started getting hungry."
    "He started noticing that he could hear the heartbeat of each member of his family."
    "He could hear the blood calling to him and he remembered the curse."
    scene bg london1855atnight with fade
    "That night, Alex went into the streets of London to find a miscreant that was breaking the law."
    show alex at left 
    a "There is nothing wrong with feeding on a criminal, right?"

    "Alex saw someone about to break into a house."
    show criminal at right with moveinbottom
    "Alex quietly crept up behind the criminal and grabbed him by the scruff of the neck."
    "He then tossed the crminial to the other side of the street, 50 feet away."
    "Alex looked down at his hands in confusion, wondering where all the extra strength came from."
    "He saw that the criminal was bleeding slightly and his bloodlust suddenly rose."
    "Suddenly, Alex was next to the crimnial, wondering how he got there so fast."
    "He grabbed the criminal by the shirt and pulled him up."
    "There was some surprising pressure in his mouth, which made Alex realize that he just grew fangs."
    "Alex sank his teeth into the criminal's neck and drank to his heart's content."
    "The criminal was completely drained of blood."

    a "I have to hide the body now. No one can find out about this secret."

    "Alex found some cement blocks and tied the blocks to the criminal's husk of a body."
    "He dragged the corpse over to the nearby rive and dumped the body."
    "Alex walked back home with his hunger temporarily satisfied, worrying about what will happen the next time he gets hungry."
    "Alex has been living this way, the last suriving member of the Knights of the Night ever since..."
#Chapter 1
label chapter1:
    scene black with dissolve
    show text "Chapter 1\nCHAPTERNAME" with Pause(1.5) with fade
    show text "Today..." with Pause(1.5) with fade
    scene black with dissolve

    #This shows the PI Office
    scene bg pioffice
    with fade

    "You sit slumped over your desk, several folders opened and scattered across your desk"

    m "Cynthia! Stop reading about all those old missing persons cases! We got a call, time to go!"

    show matthew at right with moveinbottom

    "You sigh and put down the case files."
    "You thought: They were just criminals, but there seems to be something weird with these cases."
    
    show cynthia at left with moveinleft
    c "Alright, but I'm driving!"
    m "Yes, yes. I know it is your turn."
    c "So, where are we headed?"
    m "Hampton Park."

    scene bg charlestonbridge
    with fade
    "You and Matthew got into the truck and headed out onto on the crowded streets of Charleston."

    c "What did they say on the call about the victim? Did they actually provide a decent amount of information?"
    m "Somewhat. All they really said was that the victim appears to be stabbed and was bleeding profusely."
    m "By the time EMS got there, the victim bled out and that is when we were called"
    c "That's not too bad, at least we have something to go off of."
    c "Did they say anything about the murder weapon?"
    m "No there was no mention of it"

    scene bg hamptonpark
    with fade
    "After an hour of driving, battle the morning traffic approximately 10 miles, you and Matthew finally made it to Hampton Park."
    "As you are walking into the park, you see three police officers that were trying to keep the crowd under control."
    "You and matthew started pushing through the crowd to get to the crime scene to begin your investigation."

    show po at right with moveinbottom
    po "Hey! You two!"
    po "Stop!"
    po "Where do you think you are going?"
    show cynthia at left with moveinleft
    show matthew at left with moveinleft
    menu:
        "Rude":
            jump rude
        "Polite":
            jump polite
label rude:
    c "My name is Cynthia Taylor and this is Matthew Myers"
    c "We are Sentry Investigations."
    c "You called us to investigate this murder. Now let us through."
    po "Oh, my apologies, Miss. I didn't expect you to be-- "
    c "To be what? To be dress in a jeans and a hoodie?"
    c "Do you want to be rolling around in the dirt and grass looking for leads in a dress or a suit?"
    po "Go on through."
        jump investigation
label polite:  
    c "Hello. My name is Cynthia Taylor and this is Matthew Myers."
    c "We are Sentry Investigations and are here to investigate the murder."
    po "Oh, my apologies, Miss. I didn't expect you to be here so soon. Go on through."
    c "No worries, have a good day!"
        jump investigation

label investigation:
    "You and Matthew ducked under the caution tape and started walking over to the body."
    "From the distance, you could already see that the body was surrounded by a pool of blood under a massive tree."
    "As you get closer to the body, you could see scuff marks in the dirt, like there was a fight and a huge gash in the victim's chest."
label investigate
    menu:
        "Check Time of Death"
            jump timeofdeath
        "Check for identification"
            jump identification
        "Check surrounding area"
            jump surroundingarea
        "Finished investigating"
            jump finishedinvestigating




    
    