# kid.tcl
# Create, edit, and access kid accounts
# Requires parental.tcl md5x.tcl webtcl

namespace eval kid {
    
    def kid {
        parental_id     integer                     # The rowid of the parental account this kid is associated with.
        username        "text collate nocase"       # The username the kid will use.
        password_hash   text                        # A hash of the kid's password.
        credits         integer                     # The number of credit's this kid has earned.
        name            text
        age             integer
        height          integer
        weight          integer
    }
    
    def goal {
        username        "text collate nocase"       # The username the kid.
        goal            text                        # A goal for the kid to complete.
        credits         integer                     # The amount of credits this goal is worth.
        complete        integer                     # 1=completed, 0=uncompleted.
    }
    
    # Create a kid's account.
    proc create {parental_id username password} {
        # Ensure the parental account exists.
        if { [parental::getEmail $parental_id] != ""  &&  [getID $username] == -1 } {
            kid add [list                                         \
                parental_id     $parental_id                      \
                username        $username                         \
                password_hash   [parental::getHash $password]     \
                credits         0                                 \
            ]
            return 1
        }
        # The account was not created.
        return 0
    }
    
    # Add a goal.
    proc addGoal {username goal credits} {
        # Disallow negative credits.
        if { $credits < 0 } {
            set credits 0
        }
        goal add [list              \
            username    $username   \
            goal        $goal       \
            credits     $credits    \
            complete    0           \
        ]
        return
    }
    
    # Reverse the completedness of a goal.
    proc reverseGoal {username goal_id} {
        goal mod -expr {rowid=$goal_id} {complete 0}
        set change  [goal get credits -expr {rowid=$goal_id}]
        set credits [kid get credits -expr {username=$username}]
        incr credits -$change
        kid mod -expr {username=$username} [list credits $credits]
        return
    }
    
    # Set a goal to complete.
    proc completeGoal {username goal_id} {
        goal mod -expr {rowid=$goal_id} {complete 1}
        set change  [goal get credits -expr {rowid=$goal_id}]
        set credits [kid get credits -expr {username=$username}]
        incr credits $change
        kid mod -expr {username=$username} [list credits $credits]
        return
    }
    
    # Authenticate a kid account with password. 
    proc authenticatePassword {username password} {
        set hash [parental::getHash $password]
        return [authenticatePasswordHash $username $hash]        
    }
    
    # Authenticate a kid account with a password hash. 
    proc authenticatePasswordHash {username hash} {
        set rowid [kid get rowid -expr {username=$username && password_hash=$hash}]
        if { $rowid != "" } {
            return 1
        } else {
            return 0
        }
    }
    
    # Get the unique rowid for the kid's username.
    proc getID {username} {
        set id [kid get rowid -expr {username=$username}]
        if { ![string is integer -strict $id] } {
            set id -1
        }
        return $id
    }
}