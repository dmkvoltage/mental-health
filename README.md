# **Mental Health Chatbot**

**Project**
_A chatbot for mental health support using Retrieval-Augmented Generation (RAG) and trusted data sources._

---

## **Description**

The **Mental Health Chatbot** is built to provide real-time, reliable mental health-related information and support. The chatbot uses **Retrieval-Augmented Generation (RAG)** techniques to fetch data from vectorized mental health content sourced from authoritative institutions such as the **World Health Organization (WHO)** and the **Ministry of Health and Family Welfare, Government of India**.

Messages containing crisis-related keywords receive an immediate supportive safety response without being sent to the language model.

The bot is designed to provide information while encouraging local emergency and professional support when appropriate.

---

## **Features**

- **Accurate Mental Health Information**: Fetches contextually relevant information from authoritative sources such as WHO and the Ministry of Health and Family Welfare, India.
- **Sensitive Topic Detection**: Detects crisis-related keywords and responds with immediate safety guidance.
- **Retrieval-Augmented Generation (RAG)**: Combines retrieval of relevant data from vector databases with generative responses for detailed and contextual answers.
- **Frontend-independent API**: A **FastAPI** backend that can be used by a web frontend or mobile application.
- **Conversation Sessions**: Create sessions, continue conversations, retrieve message history, and delete sessions through HTTP endpoints.
- **Real-Time Data Processing**: Uses **LangChain** for natural language processing and real-time querying of vectorized mental health data.
- **Text and PDF Processing**: Processes downloaded PDFs containing publicly available mental health data, enabling efficient querying of static resources.
- **Static Data Source**: The current data is based on static PDF documents but will be updated regularly in the future.

---

## **Project Structure**

```text
server/
  app/
    api/
      routes/       HTTP endpoints
      schemas/      Request and response models
      dependencies.py
    core/           Settings and safety rules
    models/         Chat/session domain models
    services/       Chat, knowledge base, sessions, PDF export
    main.py         FastAPI app factory and startup lifecycle
  scripts/
    build_vector_store.py
  tests/
  data/             Source PDFs
  vector_db_dir/    Generated locally; excluded from Git
  requirements.txt
  .env.example
client/
  public/assets/images/
  README.md
```

Routes handle HTTP concerns; services implement application behavior. The client folder is prepared for the future frontend; no frontend framework has been selected or scaffolded yet.

---

## **Tech Stack**

- **Python 3.13.3**
- **FastAPI** and **Uvicorn**: For the HTTP API and ASGI server.
- **LangChain**: For building conversational AI and handling text data processing.

  - **langchain-text-splitters==0.2.4**
  - **langchain-chroma==0.1.3**: For managing vectorized mental health data.
  - **langchain-huggingface==0.0.3**: For integrating HuggingFace models.
  - **langchain-groq==0.1.9**

- **HuggingFaceEmbeddings**: For embedding mental health documents and improving data retrieval.
- **PyPDF2**: For reading and extracting content from mental health-related PDFs.
- **fpdf2**: For exporting a conversation as a PDF.
- **python-dotenv**: For loading local environment configuration.

**LLM Model:**

- **ChatGroq** (Model: `llama-3.3-70b-versatile` with temperature set to 0): A large language model used to generate responses based on user input.

---

## **⭐ Star This Project**

If you find this project helpful, please consider giving it a star! Contributions are also welcome - see the [Contributing](#contributing) section below.

---

## **How to Run Locally**

### **Prerequisites**

1. **Python 3.13.3** or higher.
2. Install the project dependencies:

   ```bash
   cd server
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

   On Windows, activate the environment with `.venv\Scripts\activate`.

### **Configuration**

1. From the `server/` directory, copy `.env.example` to `.env`.
2. Set `GROQ_API_KEY` to your Groq API key.
3. Set `CORS_ORIGINS` to a comma-separated list of trusted browser frontend origins. Native mobile apps do not use browser CORS.

The vector database is generated locally and excluded from Git. If it is missing (for example, after a fresh clone), build it once from the PDFs in `data/`:

```bash
python -m scripts.build_vector_store
```

Do not rerun the index builder against an existing database for routine startup; it can append duplicate or stale chunks.

### **Running the API**

Start the API from the project directory:

```bash
cd server
uvicorn app.main:app --reload
```

The interactive API reference is available at [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs). The index-building step downloads and runs a local HuggingFace embedding model; first-time setup requires additional time and disk space.

### **API Endpoints**

All endpoints use JSON except the PDF export endpoint.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | API information and documentation link |
| `GET` | `/health` | Readiness status |
| `POST` | `/api/sessions` | Create an empty chat session |
| `GET` | `/api/sessions` | List in-memory sessions |
| `GET` | `/api/sessions/{session_id}` | Get a session and its messages |
| `DELETE` | `/api/sessions/{session_id}` | Delete a session and its history |
| `POST` | `/api/chat` | Send a message and receive a response |
| `GET` | `/api/sessions/{session_id}/export` | Download the session as a PDF |

Example request:

```http
POST /api/chat
Content-Type: application/json

{
  "message": "What are some ways to manage stress?"
}
```

`session_id` is optional: omitting it creates a session automatically. To explicitly create a session first, call `POST /api/sessions` and use the returned `session_id` in each chat request. Chat responses include the session ID, answer, retrieved source names/pages, and a `safety_notice` flag.

Sessions are held in server memory and are cleared when the API process restarts. Run one worker for this in-memory setup; multiple workers or replicas require a shared session store. Before exposing this service publicly, add authentication, request rate limiting, and secure persistent storage appropriate to your deployment.

Run the API tests with:

```bash
cd server
pip install -r requirements-dev.txt
pytest
```

---

## **Data Sources**

- **Mental Health PDFs**: The initial data for this chatbot is based on publicly available PDFs downloaded from trusted sources like WHO and the Ministry of Health and Family Welfare. These documents contain important mental health guidelines and helpline information.
- **Chroma Vector Database**: The data is vectorized and stored in the **Chroma** vector database, allowing for efficient querying and retrieval.

---

## **Future Improvements**

- **Dynamic Data Updates**: Currently, the data is static, but future iterations will implement a mechanism to update the mental health information regularly to stay current with new guidelines, data, and helplines.
- **Expanded Data Sources**: We plan to expand the data sources by integrating other publicly available mental health resources, including articles, online counseling services, and data from mental health professionals.
- **Personalized Responses**: Future versions may allow for a personalized user experience, providing suggestions based on a user’s emotional state or past interactions.
- **Integration with Mental Health Resources**: We aim to provide links to clinics, doctors, online counseling, and more.

---

## **Contributing**

⭐ **If you find this project helpful, please consider giving it a star!**

Contributions are welcome! Here's how you can help:

1. **Fork** this repository
2. Create a new branch for your feature (`git checkout -b feature/YourFeature`)
3. Make your changes and commit them (`git commit -m 'Add some feature'`)
4. Push to your branch (`git push origin feature/YourFeature`)
5. Open a **Pull Request**

Feel free to open issues for bug reports, feature requests, or questions!

---

## **License**

This project is licensed under the MIT License - see the [LICENSE](https://github.com/DeepShah1406/Mental-Health-Chatbot/blob/master/LICENSE) file for details.

---

## Contact

- 📧 Email: [codewithkingo@gmail.com](mailto:codewithkingo@gmail.com)
- 🐙 GitHub: [Kingo Kingsley](https://github.com/dmkvoltage)
- 💼 LinkedIn: [Kingo](https://www.linkedin.com/in/kingo-kingsley-krane/)

---

## **Acknowledgments**

- **LangChain**: For building robust chains of logic for querying and text processing.
- **Chroma**: For efficiently managing and querying vectorized data.
- **WHO** and **Ministry of Health and Family Welfare, Government of India**: For providing the essential mental health guidelines.
