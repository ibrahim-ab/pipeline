# Use the official Nginx image as a base
FROM nginx:alpine

# Copy the HTML files to the Nginx html directory
COPY ./html /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
