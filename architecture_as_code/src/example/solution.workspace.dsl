workspace {
    model {
        super = person "SUPer" "Un amateur de SUP voulant faire une promenade sur la scène"
        renter = person "Loueur" "Un loueur de skis dans une station"

        paymentSystem = softwareSystem "Système de payement" "Le système de payement choisi par SUP La Seine"

        enterprise "SUP La Seine" {
            supUser = person "Skiberte staff" "Les utilisateurs internes de Skiberte"
            supSystem = softwareSystem "SUP La Seine System" "Le système logiciel SUP La Seine" {
                superApp = container "Application client" "Application mobile dédiée aux pratiquants" "" "mobile" {
                    superSetProfile = super -> this "Renseigner mon profil (taille)"
                    superReserveHardware = super -> this "Réserver mon matériel près de moi depuis mon smartphone"
                    superPay = super -> this "Payer avec mon smartphone"
                    superAppSendPaymentInfo = this -> paymentSystem "Envoie les demandes de paiement des pratiquants"
                }
                supLocker = container "casier SUP La Seine" "Casier connecté avec robot intégré" "" "robot" {
                    superTakeShoes = super -> this "Prendre ma combinaison et ma pagaie dans un casier"
                    superTakeSkis = super -> this "Prendre mon paddle dans un emplacement"
                    superGiveBackShoes = super -> this "Rendre ma combinaison et ma pagaie dans un casier disponible"
                    superGiveBackPaddle = super -> this "Rendre mon paddle dans un casier disponible"
                }
                lockerBackend = container "Backend casiers" "Application centrailisant les informations des casiers" "" "" {
                    lockerToBackendNotiications = supLocker -> this "Notifie de la présence/absence de combinaisons/paddles" "messaging"
                    skiperAppGetLockerMap = superApp -> this "Obtient la carte des casiers"
                    lockerInformssuperApp = this -> superApp "Informe le pratiquant que le paddle est réservé"
                }
                lockerStorage = container "Base de données casiers" "Stocke les données des casiers" "" "bdd" {
                    lockerBackendStoresInfos = lockerBackend -> this "Stocke les informations des casiers"
                }
                renterApp = container "Application loueur" "Application mobile pour les loueurs" "" "mobile" {
                    renterGetSkisToRepair = renter -> this "Savoir quels paddles réparer"
                    renterGetStock = renter -> this "Savoir quel est l'état des stocks de paddles/combinaisons dans mes différents casiers"
                    renterGetTurnover = renter -> this "Savoir combien je gagne chaque jour"
                    lockerToRenterRepairNotification = lockerBackend -> this "Notifie le loueur que des paddles doivent être réparés" "messaging"
                    lockerToRenterStateNotification = lockerBackend -> this "Notifie le loueur de l'état de mon casier (nombre de paddles présents, nombre de combinaisons présentes)" "messaging"
                }
                superBackend = container "Backend pratiquant" "Application centralisant les informations des pratiquants" "" "" {
                    superAppWriteProfile = superApp -> this "Ecrit le profil"
                    superAppReserveHardware = superApp -> this "Réserve des paddles"
                    superBackendSendInfos = this -> lockerBackend "Envoie les infos de réservation au système de casier"
                }
                superStorage = container "Base de données pratiquant" "Stocke les données des pratiquants" "" "bdd" {
                    superBackendStoresInfos = superBackend -> this "Stocke les informations des pratiquants"
                }
            }
        }

        prod = deploymentEnvironment "Pod" {
            deploymentNode "Système de paiement de prod" {
                softwareSystemInstance paymentSystem

                deploymentNode "DBaaS" "Fournisseur DB as a service" {
                    containerInstance superStorage
                    containerInstance lockerStorage
                }
                deploymentNode "Smartphone du pratiquant" {
                    superAppInstance = containerInstance superApp
                }
                deploymentNode "Smartphone du loueur" {
                    renterAppInstance = containerInstance renterApp
                }
                deploymentNode "Casier physique" {
                    supLockerInstance = containerInstance supLocker
                }
                deploymentNode "Conteneurs managés" "Fournisseur de conteneur managés" {
                    superBackendInstance = containerInstance superBackend
                    lockerBackendInstance = containerInstance lockerBackend
                }
                deploymentNode "MaaS" "Fournisseur messaging as a service" {
                    messagingInstance = infrastructureNode "Messaging" "A messaging system to be chosen" "" "messaging" {
                        supLockerInstance -> messagingInstance "Notifie de la présence/absence de combinaisons/paddles" "messaging"
                        messagingInstance -> lockerBackendInstance "Notifie de la présence/absence de combinaisons/paddles" "messaging"
                        lockerBackendInstance -> messagingInstance "Notifie le loueur que des paddles doivent être réparés" "messaging"
                        messagingInstance -> renterAppInstance "Notifie le loueur que des paddles doivent être réparés" "messaging"
                        lockerBackendInstance -> messagingInstance "Notifie le loueur de l'état de mon casier (nombre de paddles présents, nombre de combinaisons présentes)" "messaging"
                        messagingInstance -> renterAppInstance "Notifie le loueur de l'état de mon casier (nombre de paddles présents, nombre de combinaisons présentes)" "messaging"
                    }
                }
            }
        }

    }
    views {
        systemContext supSystem supContextView {
            include *
            autoLayout
        }
        container supSystem supContainersView {
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
            logo devoxxfr.png
        }
    }
}