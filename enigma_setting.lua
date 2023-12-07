#!env luajit
#Enigma Daily Settings / Code Book Generator - www.101computing.net/enigma-daily-settings-generator/
from random import randint

TITLE = "ENIGMA M3 - UKW-B Reflector - April 1940 - Code Book"
NUMBER_OF_DAYS = 30

def rotor_selection(numberOfRotors):
    rotors = ["I","II","III","IV","V"]
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    i = randint(0, numberOfRotors-1)
    ii = randint(0, numberOfRotors-1)
    while ii==i:
      ii = randint(0, numberOfRotors-1)
    iii = randint(0, numberOfRotors-1)
    while iii==i or iii==ii:
      iii = randint(0, numberOfRotors-1)
    
    rotor_i = rotors[i]
    rotor_ii = rotors[ii]
    rotor_iii = rotors[iii]

    settings = rotor_i +  " " + rotor_ii + " " + rotor_iii
    settings = settings + (" "*(9-len(settings)))
    return settings
    
def ring_settings(numberOfRotors):  # returns ring settings
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    settings = ""
    for i in range(numberOfRotors):
      rotor = randint(0, 25)
      settings = settings + alphabet[rotor]
    return settings  
    
def plugboard_settings(numberOfPermutations):  # Plugboard steckering
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    settings = ""
    stecksA = []
    stecksB= []
    
    for i in range(numberOfPermutations):
      a = randint(0, 25)
      while a in stecksA:
        a = randint(0, 25)
      stecksA.append(a)
      
    for i in range(numberOfPermutations):
      b = randint(0, 25)
      while b in stecksA or b in stecksB:
        b = randint(0, 25)
      stecksB.append(b)

    stecksA.sort()        
    
    settings=""
    for i in range(numberOfPermutations):
       settings = settings + alphabet[stecksA[i]] + alphabet[stecksB[i]] + " "
            
        
    settings = settings[:-1]
    return settings
  
def rotor_positions(numberOfRotors):  # Rotor position
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    settings = ""
    for i in range(numberOfRotors):
      rotor = randint(0, 25)
      settings = settings + alphabet[rotor]
    return settings


def generateCodeBook(title, numberOfDays):
    print(title)
    for day in range(numberOfDays,0,-1):
        print('+------------------------------------------------+')
        if day<10:
          settings = "|  " + str(day) + " | "
        else:
          settings = "| " + str(day) + " | "
        settings = settings  + rotor_selection(5) + " | "
        settings = settings + ring_settings(3) + " | "
        settings = settings + plugboard_settings(6) + " | "
        settings = settings + rotor_positions(3) + " |"
        print(settings)
    
    print('+------------------------------------------------+')
            
generateCodeBook(TITLE, NUMBER_OF_DAYS)
