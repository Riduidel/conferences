workspace {
    model {
        skier = person "Skier" "Un skieur voulant une paire de skis et de chaussures"
        renter = person "Renter" "Un loueur de skis dans une station"

        paymentSystem = softwareSystem "Payment system" "A system able to receive payments"

        enterprise "Skiberte" {
            skiberteUser = person "Skiberte staff" "Les utilisateurs internes de Skiberte"
            skiberteSystem = softwareSystem "Skiberte System" "Le système logiciel Skiberté" {
                skierApp = container "Application skieur" "Mobile app dedicated to skiers" "" "mobile" {
                    skier -> this "Renseigner mon profil (taille, poids, pointure)"
                    skier -> this "Réserver mon matériel près de moi depuis mon smartphone"
                    skier -> this "Payer avec mon smartphone"
                    this -> paymentSystem "Envoie les demandes de paiement des skieurs"
                }
                skiberteLocker = container "casier Skiberte" "Casier connecté avec robot intégré" "" "robot" {
                    skier -> this "Prendre mes chaussures dans un casier"
                    skier -> this "Prendre mes skis dans un casier (réglés à ma taille/poids grâce à un robot régleur 🤖)"
                    skier -> this "Rendre mes chaussures dans un casier disponible"
                    skier -> this "Rendre mes skis dans un casier disponible"
                }
                lockerBackend = container "Backend casiers" "Application centrailisant les informations des casiers" "" "" {
                    skiberteLocker -> this "Notifie de la présence/absence de chaussures/skis" "messaging"
                    skierApp -> this "Obtient la carte des casiers"
                    this -> skierApp "Informe le skieur que les skis sont réservés"
                }
                lockerStorage = container "Base de données casiers" "Stocke les données des casiers" "" "bdd" {
                    lockerBackend -> this "Stocke les informations des casiers"
                }
                renterApp = container "Application loueur" "Application mobile pour les loueurs" "" "mobile" {
                    renter -> this "Savoir quels skis réparer (refarter, remettre les carres)"
                    renter -> this "Savoir quel est l'état des stocks de skis/chaussures dans mes différents casiers à skis"
                    renter -> this "Savoir combien je gagne chaque jour"
                    lockerBackend -> this "Notifie le loueur que des skis doivent être réparés" "messaging"
                    lockerBackend -> this "Notifie le loueur de l'état de monc asier (nombre de skis présents, nombre de chaussures présentes)" "messaging"
                }
                skierBackend = container "Backend skieur" "Application centralisant les informations des skieurs" "" "" {
                    skierApp -> this "Ecrit le profil"
                    skierApp -> this "Réserve des skis"
                    this -> lockerBackend "Envoie les infos de réservation au système de casier"
                }
                skierStorage = container "Base de données skieur" "Stocke les données des skieurs" "" "bdd" {
                    skierBackend -> this "Stocke les informations des skieurs"
                }
            }
        }
        prod = deploymentEnvironment "Pod" {
            deploymentNode "Système de paiement de prod" {
                softwareSystemInstance paymentSystem
                deploymentNode "DBaaS" "Fournisseur DB as a service" {
                    containerInstance skierStorage
                    containerInstance lockerStorage
                }
                deploymentNode "Smartphone du Skieur" {
                    containerInstance skierApp
                }
                deploymentNode "Smartphone du loueur" {
                    containerInstance renterApp
                }
                deploymentNode "Casier physique" {
                    containerInstance skiberteLocker
                }
                deploymentNode "Conteneurs managés" "Fournisseur de conteneur managés" {
                    containerInstance skierBackend
                    containerInstance lockerBackend
                }
            }
        }


    }
    views {
        systemContext skiberteSystem skiberteContextView {
            include *
            autoLayout
        }
        container skiberteSystem skiberteContainersView {
            include *
            autoLayout
        }
        deployment * prod prod_deployment {
            include *
            autoLayout
        }
        theme default
        styles {
            element "mobile" {
                shape MobileDevicePortrait
            }
            element "robot" {
                shape Robot
            }
            element "bdd" {
                shape Cylinder
            }
            element "messaging" {
                shape "pipe"
            }
        }
        branding {
            logo snowcamp-logo.png
        }
    }
}