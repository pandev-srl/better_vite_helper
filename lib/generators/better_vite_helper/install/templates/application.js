// Entry point per Vite
import "../assets/stylesheets/application.css";

// Import all images to include them in Vite manifest
// Images will be available via vite_image_tag helper
import.meta.glob("../assets/images/**/*.{png,jpg,jpeg,gif,svg,webp,avif,ico}", {
  eager: true,
});

// Il tuo codice JavaScript qui
