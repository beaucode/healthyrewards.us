# parental.tcl
# Create, edit, and access parental accounts
# Requires md5x.tcl webtcl

namespace eval parental {
    
    def parent {
        email           "TEXT collate nocase"       # The email the parent will use to login.
        password_hash   TEXT                        # A hash of the user's password.
    }
    
    
    # Create a parental account.
    proc create {email password} {
        # Ensure an email was provided and that it is not already in use.
        if {  $email != ""  &&  [getID $email] == -1 } {
            parent add [list                            \
                email            $email                 \
                password_hash    [getHash $password]    \
            ]
            # The account was successfully created.
            return 1
        }
        # This email is already in use, so the account was not created.
        return 0
    }
    
    # Authenticate a parent account with password. 
    proc authenticatePassword {email password} {
        set hash [getHash $password]
        return [authenticatePasswordHash $email $hash]        
    }
    
    # Authenticate a parent account with a password hash. 
    proc authenticatePasswordHash {email hash} {
        set rowid [parent get rowid -expr {email=$email && password_hash=$hash}]
        if { $rowid != "" } {
            return 1
        } else {
            return 0
        }
    }
    
    # Get the unique rowid for the parental account.
    proc getID {email} {
        # Find the rowid that contains this email address.
        set id [parent get rowid -expr {email=$email}]
        if { ![string is integer -strict $id] } {
            set id -1
        }
        return $id
    }
    
    # Get the email associated with the specified id.
    proc getEmail {id} {
        return [parent get email -expr {rowid=$id}]
    }
    
    # Generate a hash for the provided password.
    proc getHash {password} {
        set salt "blah123000"
        binary scan [md5::md5 "$salt$password"] H* hash
        return $hash
    }
    
}