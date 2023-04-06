workspace {
    model {
        super = person "SUPer" "Un amateur de SUP voulant faire une promenade sur la scène"
        renter = person "Loueur" "Un loueur de skis dans une station"
        
        enterprise "SUP La Seine" {
            supSystem = softwareSystem "SUP La Seine System" "Le système logiciel SUP La Seine" {
                superApp = container "Application client" "Application mobile dédiée aux pratiquants" "" "mobile" {
                }
                supLocker = container "casier SUP La Seine" "Casier connecté avec robot intégré" "" "robot" {
                }
                lockerBackend = container "Backend casiers" "Application centrailisant les informations des casiers" "" "" {
                }
                lockerStorage = container "Base de données casiers" "Stocke les données des casiers" "" "bdd" {
                }
                renterApp = container "Application loueur" "Application mobile pour les loueurs" "" "mobile" {
                }
                superBackend = container "Backend pratiquant" "Application centralisant les informations des pratiquants" "" "" {
                }
                superStorage = container "Base de données pratiquant" "Stocke les données des pratiquants" "" "bdd" {
                }
            }
        }

        paymentSystem = softwareSystem "Système de payement" "Le système de payement choisi par SUP La Seine"
    }
    views {
    }
}