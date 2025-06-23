// Sauvegarder les interventions dans le navigateur
function saveInterventions(interventions) {
    localStorage.setItem('scapcb-interventions', JSON.stringify(interventions));
}

// Charger les interventions depuis le navigateur
function loadInterventions() {
    const data = localStorage.getItem('scapcb-interventions');
    return data ? JSON.parse(data) : [];
}

// Effacer toutes les interventions
function clearInterventions() {
    localStorage.removeItem('scapcb-interventions');
}

// Exemple d'utilisation :
// let interventions = loadInterventions();
// interventions.push({ id: 1, titre: "Nouvelle intervention", ... });
// saveInterventions(interventions);