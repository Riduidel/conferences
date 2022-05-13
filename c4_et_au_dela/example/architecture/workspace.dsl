workspace {
    model {
       // TODO Add Software System with 02_system_model
       owner = person "Owner" "Pet Owner"
       vet = person "Veterinary" "Veterinary working at pet clinic"
       petclinic = softwareSystem "Pet Clinic" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets." {
          // TODO Add containers with 04_container_model
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
       dev = deploymentEnvironment "dev" {
           deploymentNode "Developer laptop" {
               deploymentNode "Docker container - web server" {
                   deploymentNode "Tomcat" {
                       containerInstance webapp
                   }
               }
               deploymentNode "Docker container - DB" {
                   deploymentNode "Database server" {
                       containerInstance db
                   }
               }
           }
       }
    }

    views {
       styles {
       }

       // TODO add System views with 03_system_view
       systemLandscape landscape {
           include *
           autoLayout
       }

       // TODO add Container views with 05_container_view
       container petClinic {
           include *
           autoLayout
       }

       // TODO add Component view with 09_components_view

       // TODO add Deployment view with 07_deployment_view
       deployment * dev "Dev_machine" "Deployment of pet clinic on dev machine" {
           include *
           autoLayout
       }

       theme default
    }
}