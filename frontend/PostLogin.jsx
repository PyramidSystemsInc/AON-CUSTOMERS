import React, { useState, useEffect } from 'react';

const requiredFields = [
  'Phone', 'Country', 'Industry', 'Annual Revenue', 'Employee Count', 'Capability Needed'
];

export default function PostLogin({ user }) {
  const [formData, setFormData] = useState({});
  const [missingFields, setMissingFields] = useState(requiredFields);
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    if (user) {
      const initialForm = {};
      const missing = [];

      requiredFields.forEach((field) => {
        if (user[field]) {
          initialForm[field] = user[field];
        } else {
          missing.push(field);
        }
      });

      setFormData(initialForm);
      setMissingFields(missing);
    }
  }, [user]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const isComplete = missingFields.every(field => formData[field]);
    if (!isComplete) {
      alert('Please fill in all required fields.');
      return;
    }
    // TODO: Add backend submission logic here (e.g., POST to server or save to CSV)
    setSubmitted(true);
  };

  if (!user?.firstName) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center' }}>
        <h1 style={{ color: '#c8102e' }}>AON</h1>
        <p>Please sign in with LinkedIn to begin.</p>
        <a
          href="/auth/linkedin"
          style={{
            backgroundColor: '#0077B5',
            color: 'white',
            padding: '0.75rem 2rem',
            borderRadius: '5px',
            textDecoration: 'none',
            display: 'inline-block',
            marginTop: '1rem'
          }}
        >
          Sign in with LinkedIn
        </a>
      </div>
    );
  }

  const userName = user.firstName;

  if (submitted) {
    return (
      <div style={{ padding: '2rem', textAlign: 'center', color: 'green' }}>
        <h2>Thank you, {userName}!</h2>
        <p>Your information has been submitted successfully.</p>
        <p>An AON advisor will reach out shortly.</p>
      </div>
    );
  }

  return (
    <div style={{ padding: '2rem' }}>
      <h1 style={{ color: '#c8102e' }}>AON</h1>
      <h2>Hello {userName}, just a few more details…</h2>
      <form onSubmit={handleSubmit}>
        {missingFields.map((field) => (
          <div key={field} style={{ margin: '1rem 0' }}>
            <label>{field}:&nbsp;</label>
            <input
              type="text"
              name={field}
              onChange={handleChange}
              value={formData[field] || ''}
              style={{ padding: '0.5rem', width: '60%' }}
              required
            />
          </div>
        ))}
        <button
          type="submit"
          style={{
            padding: '0.75rem 2rem',
            backgroundColor: '#c8102e',
            color: 'white',
            border: 'none',
            borderRadius: '5px'
          }}
        >
          Submit
        </button>
      </form>
    </div>
  );
}
