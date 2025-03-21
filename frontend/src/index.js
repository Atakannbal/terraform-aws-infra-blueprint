import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

function App() {
  const podName = process.env.REACT_APP_POD_NAME || "Unknown Pod";
  const podIp = process.env.REACT_APP_POD_IP || "Unknown IP";

  const [num1, setNum1] = useState('');
  const [num2, setNum2] = useState('');
  const [result, setResult] = useState('');

  const calculate = async () => {
    try {
      const res = await fetch(`/sum?${num1}+${num2}`);
      const data = await res.text();
      setResult(data);
    } catch (error) {
      setResult('Error');
    }
  };

  return (
    <div>
      <h1>Pod Name: {podName}</h1>
      <h2>Pod IP: {podIp}</h2>
      <input type="number" value={num1} onChange={(e) => setNum1(e.target.value)} placeholder="Number 1" />
      <input type="number" value={num2} onChange={(e) => setNum2(e.target.value)} placeholder="Number 2" />
      <button onClick={calculate}>Calculate</button>
      <input type="text" value={result} readOnly placeholder="Result" />
    </div>
  );
}

const root = createRoot(document.getElementById('root'));
root.render(<App />);