
// sdk stuff
import structs/[List, ArrayList]

/**
 * The set of rules for a given level
 */
LevelDef: class {

    numEnemies := 1
    numBalls := 20

    bordersHurt := false
    selfHurt := false

    fragile := false
    spiky := false

    message: String

    init: func (=message)

    init: func ~inherit (daddy: LevelDef, =message) {
        numEnemies = daddy numEnemies
        numBalls = daddy numBalls

        bordersHurt = daddy bordersHurt
        selfHurt = daddy selfHurt

        fragile = daddy fragile
        spiky = daddy spiky
    }

    getList: static func -> List<This> {
        defs := ArrayList<This> new()

        click := "Click"
        version (android || ios) {
            click = "Touch"
        }

        {
            def := This new("%s and hold to grow balls | Fill 66%" format(click))

            def numEnemies = 0
            defs add(def)
        }

        {
            def := This new(defs last(), "Enemies hurt while you grow")
            def numEnemies = 2
            defs add(def)
        }

        {
            def := This new(defs last(), "The more enemies the harder")
            def numEnemies = 3
            defs add(def)
        }

        {
            def := This new(defs last(), "That was obviously too easy")
            def numEnemies = 4
            defs add(def)
        }

        {
            def := This new(defs last(), "Is the whole game like this?")
            def numEnemies = 5
            defs add(def)
        }

        {
            def := This new(defs last(), "Your hubris is taking over")
            def numEnemies = 6
            defs add(def)
        }

        {
            def := This new(defs last(), "Last one before new rule")
            def numEnemies = 7
            defs add(def)
        }

        {
            def := This new(defs last(), "NEW RULE | Now the borders hurt")
            def bordersHurt = true
            def numEnemies = 3
            defs add(def)
        }

        {
            def := This new(defs last(), "Not so cocky now eh?")
            def numEnemies = 4
            defs add(def)
        }

        {
            def := This new(defs last(), "You can do it")
            def numEnemies = 5
            defs add(def)
        }

        {
            def := This new(defs last(), "Going strong")
            def numEnemies = 6
            defs add(def)
        }

        {
            def := This new(defs last(), "Just one more")
            def numEnemies = 7
            defs add(def)
        }

        {
            def := This new(defs last(), "NEW RULE | You are hurting yourself")
            def selfHurt = true
            def numEnemies = 3
            defs add(def)
        }

        {
            def := This new(defs last(), "Why are you hurting yourself?")
            def numEnemies = 4
            defs add(def)
        }

        {
            def := This new(defs last(), "Do you find solace in the gesture?")
            def numEnemies = 5
            defs add(def)
        }

        {
            def := This new(defs last(), "Do you like hurting other people?")
            def numEnemies = 6
            defs add(def)
        }

        {
            def := This new(defs last(), "Do you just want to put an end to it?")
            def numEnemies = 7
            defs add(def)
        }

        {
            def := This new(defs last(), "Reinforcements on the way")
            def numEnemies = 8
            defs add(def)
        }

        {
            def := This new(defs last(), "NEW RULE | Life is fragile | Friends matter")
            def fragile = true
            def numBalls = 40
            def numEnemies = 1
            defs add(def)
        }

        {
            def := This new(defs last(), "Capturing is not always the best strategy")
            def numEnemies = 2
            defs add(def)
        }

        {
            def := This new(defs last(), "What we need is a hero")
            def numEnemies = 3
            defs add(def)
        }

        {
            def := This new(defs last(), "EVOLUTION | %s to make the brightest heroes" format(click))
            def bordersHurt = false
            def selfHurt = false
            def spiky = true

            def numBalls = 40
            def numEnemies = 4
            defs add(def)
        }

        {
            def := This new(defs last(), "Building up" format(click))
            def numEnemies = 5
            defs add(def)
        }

        {
            def := This new(defs last(), "Capture used to be easier" format(click))
            def numEnemies = 6
            defs add(def)
        }

        {
            def := This new(defs last(), "Almost there" format(click))
            def numEnemies = 7
            defs add(def)
        }


        defs
    }
    
}

