;;try to copy a simple spatial PD game with mobile agents





;;turtle variables
turtles-own[
 energy ;turtles accumulated energy
 played? ;has the turtle played this round?
]

;;global parameters
globals[
  reproduce-threshold
  reproduce-cost
  payoff-CC
  payoff-DC
  payoff-DD
  max-energy
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SETUP PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  ask patches [set pcolor white]
  initialize-variables
  create-agents num-agents init-coop-freq
  reset-ticks
end

to initialize-variables
  ;;initialize all variables
  set reproduce-threshold 100
  set reproduce-cost 50
  set payoff-CC 2 ;used to be 3, CHANGED to 2
  set payoff-CD 2 ;used to be -1, CHANGED to 2
  set payoff-DC 2 ;used to be 5, CHANGED to 2
  set payoff-DD 2 ;used to be 0, CHANGED to 2
  set max-energy 150
end

to create-agents [n coop-freq]
  create-turtles n[
    ifelse random-float 1 < coop-freq
    [set color green] ;used to be "blue", CHANGED to "green"
    [set color red]
    set shape "square" ;used to be "circle", CHANGED to "square"
    set size 1
    move-to one-of patches with [not any? other turtles-here]
    set energy (random 50 + 1)
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BEHAVIOR PROCEDURES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  if not any? turtles [ stop ] ;stop the simulation if everyone is dead
  let ngreen (count turtles with [color = green]) ; THIS LINE HAS BEEN ADDED, gets the count of cooperators for the graph
  ask turtles [set played? false]
  ask turtles[
    if energy <= 0 [die] ;;die if not enough energy

    ;;play PD game and collect payoffs
    if (not played?)[ interact ] ;;find coplayer

    ;;reproduce
    if (energy >= reproduce-threshold and (count turtles < carrying-capacity))
      [reproduce]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; ADDED BLOCK
    ;;
    ;; The below code block decides, for each tick, for each cooperator
    ;; if it is going to suicide or not (the frequency of this happening
    ;; is defined in the interface by the varibale "suicide-rate"). When
    ;; a suicide occurs, all the other green cooperators are summoned
    ;; and the energy of the fallen cooperator is spread among them.
    ;;
    ;;
    ;;
    ;;
    ifelse color = green ;if I'm a cooperator
    [
      ifelse random-float 1 < suicide-rate
      [
        let currenergy energy

        ask turtles with [color = green]
        [
          ifelse random-float 1 < 1
          [
            set energy (energy + (currenergy / ngreen)) ;distribute energy
          ]
          [
          ]
        ]
        set energy 0
      ]
      [
      ]
    ]
    [
    ]
    ;;
    ;; ADDED BLOCK
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;energy loss
    set energy (energy - cost-of-living)
    if energy > max-energy [ set energy max-energy ]

    ;;movement
    if (not played?) [ move2 ];;if didn't find coplayer, move
  ]
  tick
end


;;Find an interaction partner and play PD game with them
to interact
  let partner (one-of ((turtles-on neighbors) with [played? = false]))
  ;;the rest only runs if a partner is found
  if partner != nobody [
    set played? true
    ask partner [set played? true]

    ifelse color = green ;if I'm a cooperator  ;used to be "blue", CHANGED to "green"
    [
      ifelse ([color] of partner) = green  ;used to be "blue", CHANGED to "green"
      [
        set energy (energy + payoff-CC)
        ask partner [set energy (energy + payoff-CC)]
      ]
      [
        set energy (energy + payoff-CD)
        ask partner [set energy (energy + payoff-DC)]
      ]
    ]
    [ ;if I'm a defector
      ifelse ([color] of partner) = green  ;used to be "blue", CHANGED to "green"
      [
        set energy (energy + payoff-DC)
        ask partner [set energy (energy + payoff-CD)]
      ]
      [
        set energy (energy + payoff-DD)
        ask partner [set energy (energy + payoff-DD)]
      ]
    ]
  ]
end


;;move to a random new location if no one to play with
;;for now, just move to any available space in the Moore neigborhood.
to move
  let new-patch (one-of neighbors with [ not any? turtles-here ])
  if (new-patch != nobody)
  [
    move-to new-patch
  ]
end

;;movement more in line with original Am Nat model
;;agent chooses square to move to, and only then checks if it's occupied
to move2
  let new-patch (one-of neighbors)
  if (not any? turtles-on new-patch)
  [
    move-to new-patch
  ]
end


;;attempt to place a duplicate agent in a neighboring cell
to reproduce
  let new-patch (one-of neighbors with [ not any? turtles-here ])
  if (new-patch != nobody)
  [
    set energy (energy - reproduce-cost)
    hatch 1 [
      set energy reproduce-cost
      move-to new-patch
      set played? false
  ]
  ]
end

;;random agents lose energy if population exceeds carrying capacity
to cull-herd
  if (count turtles > carrying-capacity)
  [
    ask one-of turtles [
      set energy ( energy - 10 )
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOTTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report rep-coop-freq
  let Nc (count turtles with [ color = green ])  ;used to be "blue", CHANGED to "green"
  let N (count turtles)
  report Nc / N
end

to-report rep-tick-maximum
  let tick-max ticks
  report tick-max
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright 2017 Paul Smaldino
;; See info tab for details
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
205
31
510
337
-1
-1
4.243
1
10
1
1
1
0
1
1
1
-35
34
-35
34
1
1
1
ticks
30.0

SLIDER
20
375
192
408
num-agents
num-agents
1
4900
100.0
1
1
NIL
HORIZONTAL

SLIDER
20
417
192
450
init-coop-freq
init-coop-freq
0
1
0.5
.01
1
NIL
HORIZONTAL

BUTTON
21
32
193
66
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
22
72
108
106
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
72
194
106
Go (x1)
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
204
375
376
408
carrying-capacity
carrying-capacity
1
4900
4900.0
1
1
NIL
HORIZONTAL

SLIDER
22
194
194
227
cost-of-living
cost-of-living
0
2
0.5
.50
1
NIL
HORIZONTAL

SLIDER
205
418
377
451
payoff-CD
payoff-CD
-10
3
2.0
.1
1
NIL
HORIZONTAL

PLOT
521
30
900
214
Populations
Ticks
Turtles
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"cooperators" 1.0 0 -13840069 true "" "plot count turtles with [color = green]"
"defectors" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"

PLOT
587
223
900
373
Cooperator frequency
ticks
coop freq
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "plot rep-coop-freq"

MONITOR
522
225
580
270
N
count turtles
17
1
11

BUTTON
22
114
195
147
[X] Record simulation [X]
;;run-simulation-to-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
522
276
579
321
ticks
ticks
17
1
11

TEXTBOX
25
173
191
192
EXPERIMENT VARIABLES
14
0.0
1

TEXTBOX
23
351
193
372
CONSTANT VARIABLES
14
0.0
1

CHOOSER
22
235
198
280
suicide-rate
suicide-rate
1.0E-4 0.001 0.01 0.1 0.9
2

@#$#@#$#@
## EDITS TO THIS DOCUMENT

This NetLogo file is the result of modification of the original NetLogo instatiation created by Paul Smaldino in 2017. The sole purpose of this NetLogo file is to serve
as a simulation environment for a tested hypothesis. Changes have been made by
Adam Jaamour and Andrea Lissak in 2019.

## WHAT IS IT?

The below code block decides, for each tick, for each cooperator
if it is going to suicide or not (the frequency of this happening
is defined in the interface by the varibale "suicide-rate"). When
a suicide occurs, all the other green cooperators are summoned
and the energy of the fallen cooperator is spread among them.

This is a game model in which agents gain energy by being close to any other agent. Energy is used to reproduce locally. Being alive costs energy depending on the cost of living slider in the interface, and so agents must generate energy stay alive in harsh environments. 
This is a replication of the model presented in Smaldino, Schank, & McElreath (2013) and Smaldino (2013).
See below for paper details. 

## HOW IT WORKS

See referenced papers for details. 

## CREDITS AND REFERENCES

This model is a replication of one previously presented in the following two papers: 

Smaldino PE, Schank JC, McElreath R (2013) Increased costs of cooperation help cooperators in the long run. American Naturalist 181: 451-463.

Smaldino PE (2013) Cooperation in harsh environments and the emergence of spatial patterns. Chaos, Solitons, and Fractals 56: 6-12.

This NetLogo instatiation was created by Paul Smaldino in 2017.

## COPYRIGHT AND LICENSE

Copyright 2017 Paul Smaldino.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
