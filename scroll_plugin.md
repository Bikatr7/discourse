# Discourse Iframe Embed

## Setup

1. **Create component**
   - Admin → Customize → Themes → Install → Create New → Component
   - Name: "Scroll Embed"
   - Add to default theme

2. **Code**
   
   **CSS Section (Common → CSS):**
   ```css
   /* No CSS needed - pure JavaScript approach */
   ```

   **Body Section (Common → Body):**
   ```html
   <script>
   function addIframeToPost() {
     const post1 = document.getElementById('post_1');
     
     if (post1) {
       const topicBody = post1.querySelector('.topic-body');
       
       if (topicBody) {
         // Check if iframe already exists to avoid duplicates
         if (topicBody.querySelector('.custom-iframe-container')) {
           return true;
         }
         
         const iframeContainer = document.createElement('div');
         iframeContainer.className = 'custom-iframe-container';
         iframeContainer.style.cssText = 'margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; padding: 10px; background: white;';
         iframeContainer.innerHTML = '<iframe src="http://localhost:3001/embed/source" width="100%" height="600" frameborder="0" referrerpolicy="unsafe-url" title="Negation-Game Source Embed"></iframe>';
         topicBody.appendChild(iframeContainer);
         return true;
       }
     }
     
     return false;
   }

   // Try immediately, then poll if needed
   if (!addIframeToPost()) {
     let attempts = 0;
     const maxAttempts = 20;
     
     const interval = setInterval(() => {
       attempts++;
       
       if (addIframeToPost() || attempts >= maxAttempts) {
         clearInterval(interval);
       }
     }, 500);
   }
   </script>
   ```

## How it works

Shows iframe after the first post on every topic page. Embed app runs on `:3001`, Discourse on `:3000/:4200`.

Uses polling because Discourse loads posts dynamically - `DOMContentLoaded` fires too early. Tries every 500ms for 10 seconds max.

The `referrerpolicy="unsafe-url"` fixes the referer issue - without it you only get the root domain instead of the full topic URL.

## What you get

- Iframe after first post only
- Fixed size: 100% width, 600px height  
- Border with rounded corners
- Works on all topic pages
- No duplicate iframes (checks first) 