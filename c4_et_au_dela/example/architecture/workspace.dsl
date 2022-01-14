workspace {
    model {
        owner = person "Owner" "Pet Owner"
        vet = person "Veterinary" "Veterinary working at pet clinic"
        petclinic = softwareSystem "Pet Clinic" "Allows employees to view and manage information regarding the veterinarians, the clients, and their pets."

        owner -> petclinic "Book an apointment"
        vet -> petclinic "Check apointments"
    }

    views {
        systemLandscape landscape {
            include *
            autoLayout
        }
        theme default
        branding {
            logo https://snowcamp.io/img/alpes-snow-full-illustration.webp
        }
    }
}