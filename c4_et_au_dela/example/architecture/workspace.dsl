workspace {
    model {
        owner = person "Owner" "Pet Owner"
        vet = person "Veterinary" "Veterinary working at pet clinic"
        petclinic = softwareSystem "Pet Clinic" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets." {
            db = container "Database" "Stores informations regarding the veterinarians, the clients, and their pets." "RDBMS"
            webapp = container "Web Application" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets." "Java, Spring" {
               // TODO add components with 08_components_model
            }
            webapp -> db "Read and writes informations"
            owner -> webapp
            vet -> webapp
        }
        
        owner -> petclinic "Book an apointment"
        vet -> petclinic "Check apointments"
        
        // TODO Add deployment model with 06_deployment_model
    }

    views {
       styles {
       }

        systemLandscape landscape {
            include *
            autoLayout
        }

        container petclinic {
            include *
            autoLayout
        }

       // TODO add Component view with 09_components_view

       // TODO add Deployment view with 07_deployment_view

       theme default
    }
}