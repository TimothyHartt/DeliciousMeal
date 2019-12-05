let container    = document.querySelector('.canvas')
let toggleButton = document.querySelector('.toggle-button')

toggleButton.addEventListener('click', (e) => {
  e.preventDefault();
  container.classList.toggle('show-nav');
});
