document.getElementById('postForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Evita que el formulario se envíe de la manera tradicional

    // Obtiene los valores del formulario
    const username = document.getElementById('username').value;
    const message = document.getElementById('message').value;

    // Crea un nuevo post
    const post = document.createElement('article');
    post.classList.add('post');
    post.innerHTML = `<h3>${username}</h3><p>${message}</p>`;

    // Agrega el nuevo post a la sección de posts
    document.getElementById('posts').appendChild(post);

    // Limpia el formulario
    document.getElementById('postForm').reset();
});

