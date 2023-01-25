workspace {
    model {
        skier = person "Skier" "Un skieur voulant une paire de skis et de chaussures"
        renter = person "Renter" "Un loueur de skis dans une station"

        paymentSystem = softwareSystem "Payment system" "A system able to receive payments"

        enterprise "Skiberte" {
            skiberteUser = person "Skiberte staff" "Les utilisateurs internes de Skiberte"
            skiberteSystem = softwareSystem "Skiberte System" "Le système logiciel Skiberté" {
                skierApp = container "Application skieur" "Mobile app dedicated to skiers" "" "mobile" {
                    skierSetProfile = skier -> this "Renseigner mon profil (taille, poids, pointure)"
                    skierReserveHardware = skier -> this "Réserver mon matériel près de moi depuis mon smartphone"
                    skierPay = skier -> this "Payer avec mon smartphone"
                    skierAppSendPaymentInfo = this -> paymentSystem "Envoie les demandes de paiement des skieurs"
                }
                skiberteLocker = container "casier Skiberte" "Casier connecté avec robot intégré" "" "robot" {
                    skierTakeShoes = skier -> this "Prendre mes chaussures dans un casier"
                    skierTakeSkis = skier -> this "Prendre mes skis dans un casier (réglés à ma taille/poids grâce à un robot régleur 🤖)"
                    skierGiveBackShoes = skier -> this "Rendre mes chaussures dans un casier disponible"
                    skierGiveBackSkis = skier -> this "Rendre mes skis dans un casier disponible"
                }
                lockerBackend = container "Backend casiers" "Application centrailisant les informations des casiers" "" "" {
                    lockerToBackendNotiications = skiberteLocker -> this "Notifie de la présence/absence de chaussures/skis" "messaging"
                    skiperAppGetLockerMap = skierApp -> this "Obtient la carte des casiers"
                    lockerInformsSkierApp = this -> skierApp "Informe le skieur que les skis sont réservés"
                }
                lockerStorage = container "Base de données casiers" "Stocke les données des casiers" "" "bdd" {
                    lockerBackendStoresInfos = lockerBackend -> this "Stocke les informations des casiers"
                }
                renterApp = container "Application loueur" "Application mobile pour les loueurs" "" "mobile" {
                    renterGetSkisToRepair = renter -> this "Savoir quels skis réparer (refarter, remettre les carres)"
                    renterGetStock = renter -> this "Savoir quel est l'état des stocks de skis/chaussures dans mes différents casiers à skis"
                    renterGetTurnover = renter -> this "Savoir combien je gagne chaque jour"
                    lockerToRenterRepairNotification = lockerBackend -> this "Notifie le loueur que des skis doivent être réparés" "messaging"
                    lockerToRenterStateNotification = lockerBackend -> this "Notifie le loueur de l'état de mon casier (nombre de skis présents, nombre de chaussures présentes)" "messaging"
                }
                skierBackend = container "Backend skieur" "Application centralisant les informations des skieurs" "" "" {
                    skierAppWriteProfile = skierApp -> this "Ecrit le profil"
                    skierAppReserveHardware = skierApp -> this "Réserve des skis"
                    skierBackendSendInfos = this -> lockerBackend "Envoie les infos de réservation au système de casier"
                }
                skierStorage = container "Base de données skieur" "Stocke les données des skieurs" "" "bdd" {
                    skierBackendStoresInfos = skierBackend -> this "Stocke les informations des skieurs"
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
                    skierAppInstance = containerInstance skierApp
                }
                deploymentNode "Smartphone du loueur" {
                    renterAppInstance = containerInstance renterApp
                }
                deploymentNode "Casier physique" {
                    skiberteLockerInstance = containerInstance skiberteLocker
                }
                deploymentNode "Conteneurs managés" "Fournisseur de conteneur managés" {
                    skierBackendInstance = containerInstance skierBackend
                    lockerBackendInstance = containerInstance lockerBackend
                }
                deploymentNode "MaaS" "Fournisseur messaging as a service" {
                    messagingInstance = infrastructureNode "Messaging" "A messaging system to be chosen" "" "messaging" {
                        skiberteLockerInstance -> messagingInstance "Notifie de la présence/absence de chaussures/skis" "messaging"
                        messagingInstance -> lockerBackendInstance "Notifie de la présence/absence de chaussures/skis" "messaging"
                        lockerBackendInstance -> messagingInstance "Notifie le loueur que des skis doivent être réparés" "messaging"
                        messagingInstance -> renterAppInstance "Notifie le loueur que des skis doivent être réparés" "messaging"
                        lockerBackendInstance -> messagingInstance "Notifie le loueur de l'état de mon casier (nombre de skis présents, nombre de chaussures présentes)" "messaging"
                        messagingInstance -> renterAppInstance "Notifie le loueur de l'état de mon casier (nombre de skis présents, nombre de chaussures présentes)" "messaging"
                    }
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
            exclude lockerToBackendNotiications
            exclude lockerToRenterRepairNotification
            exclude lockerToRenterStateNotification
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