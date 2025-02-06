'use strict'
const axios = require('axios');
const { ethers } = require("ethers");

const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=xxxxxxxxxxxxx";

let countRequest = 0;

const RPC_URL = "https://opt-sepolia.g.alchemy.com/v2/xxxxxxxxxxx";
const provider = new ethers.JsonRpcProvider(RPC_URL);

const PRIVATE_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

const CONTRACT_ADDRESS = "0x9E396bF5cd77B5D6098e08c10bd7fC1E6b3A420a";

const contractABI = [
	{
		"inputs": [],
		"name": "acceptOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "_skills",
				"type": "string[]"
			}
		],
		"name": "addPerson",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "uint256[]",
				"name": "_members",
				"type": "uint256[]"
			}
		],
		"name": "createTeam",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "EmptySource",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "requestId",
				"type": "bytes32"
			},
			{
				"internalType": "bytes",
				"name": "response",
				"type": "bytes"
			},
			{
				"internalType": "bytes",
				"name": "err",
				"type": "bytes"
			}
		],
		"name": "handleOracleFulfillment",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "NoInlineSecrets",
		"type": "error"
	},
	{
		"inputs": [],
		"name": "OnlyRouterCanFulfill",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "requestId",
				"type": "bytes32"
			}
		],
		"name": "UnexpectedRequestID",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "OwnershipTransferRequested",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			}
		],
		"name": "PersonAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "RequestFulfilled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "id",
				"type": "bytes32"
			}
		],
		"name": "RequestSent",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "bytes32",
				"name": "requestId",
				"type": "bytes32"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "teamsWithMembers",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "bytes",
				"name": "response",
				"type": "bytes"
			},
			{
				"indexed": false,
				"internalType": "bytes",
				"name": "err",
				"type": "bytes"
			}
		],
		"name": "Response",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint64",
				"name": "subscriptionId",
				"type": "uint64"
			}
		],
		"name": "sendRequest",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "requestId",
				"type": "bytes32"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string[]",
				"name": "skills",
				"type": "string[]"
			}
		],
		"name": "SkillsUpdated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256[]",
				"name": "members",
				"type": "uint256[]"
			}
		],
		"name": "TeamCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "uint256[]",
						"name": "members",
						"type": "uint256[]"
					}
				],
				"indexed": false,
				"internalType": "struct CVToTeam.Team[]",
				"name": "teams",
				"type": "tuple[]"
			}
		],
		"name": "TeamsGenerated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "string[]",
				"name": "_skills",
				"type": "string[]"
			}
		],
		"name": "updateSkills",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllPeople",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string[]",
						"name": "skills",
						"type": "string[]"
					}
				],
				"internalType": "struct CVToTeam.Person[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getPerson",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			}
		],
		"name": "getTeam",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string[]",
						"name": "skills",
						"type": "string[]"
					}
				],
				"internalType": "struct CVToTeam.Person[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "teamsWithMembers",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

const cvs = [
	{
	"name": "John Smith",
	"contact": {
		"email": "john.smith@email.com",
		"phone": "+44 7712345678",
		"linkedin": "https://linkedin.com/in/johnsmith"
	},
	"summary": "Full Stack Developer with expertise in web applications and cloud computing.",
	"experience": [
		{
		"position": "Full Stack Developer",
		"company": "Tech Solutions",
		"location": "London, UK",
		"period": "2019 - Present",
		"responsibilities": [
			"Developing and maintaining web applications",
			"Optimizing performance and security",
			"Leading a development team"
		]
		},
		{
		"position": "Backend Developer",
		"company": "CodeWorks",
		"location": "Manchester, UK",
		"period": "2016 - 2019",
		"responsibilities": [
			"Creating RESTful APIs",
			"Database integration",
			"Developing microservices"
		]
		}
	],
	"education": {
		"degree": "BSc in Computer Science",
		"institution": "University of London",
		"year_of_completion": 2016
	},
	"skills": ["JavaScript", "Node.js", "React", "MongoDB", "AWS", "Docker"],
	"languages": ["English (Native)", "Spanish (Intermediate)"]
	},
	{
	"name": "Sarah Johnson",
	"contact": {
		"email": "sarah.johnson@email.com",
		"phone": "+44 7798765432",
		"linkedin": "https://linkedin.com/in/sarahjohnson"
	},
	"summary": "Front-End Developer passionate about UI/UX and modern web technologies.",
	"experience": [
		{
		"position": "Front-End Developer",
		"company": "WebVision",
		"location": "London, UK",
		"period": "2020 - Present",
		"responsibilities": [
			"Building responsive and accessible user interfaces",
			"Working with designers to create seamless UX",
			"Optimizing website performance"
		]
		},
		{
		"position": "UI Engineer",
		"company": "CreativeTech",
		"location": "Bristol, UK",
		"period": "2017 - 2020",
		"responsibilities": [
			"Developing interactive user interfaces",
			"Ensuring cross-browser compatibility",
			"Implementing animations and transitions"
		]
		}
	],
	"education": {
		"degree": "BSc in Software Engineering",
		"institution": "University of Manchester",
		"year_of_completion": 2017
	},
	"skills": ["HTML", "CSS", "JavaScript", "React", "Figma", "SASS"],
	"languages": ["English (Fluent)", "French (Basic)"]
	},
	{
	"name": "Michael Brown",
	"contact": {
		"email": "michael.brown@email.com",
		"phone": "+44 7786543210",
		"linkedin": "https://linkedin.com/in/michaelbrown"
	},
	"summary": "Backend Developer specializing in high-performance API development.",
	"experience": [
		{
		"position": "Senior Backend Developer",
		"company": "DataCorp",
		"location": "Manchester, UK",
		"period": "2018 - Present",
		"responsibilities": [
			"Developing and optimizing scalable APIs",
			"Database design and query optimization",
			"Ensuring security best practices"
		]
		}
	],
	"education": {
		"degree": "MSc in Software Development",
		"institution": "University of Edinburgh",
		"year_of_completion": 2018
	},
	"skills": ["Python", "Django", "PostgreSQL", "Redis", "GraphQL"],
	"languages": ["English (Native)", "German (Intermediate)"]
	},
	{
		"name": "Emily White",
		"contact": {
			"email": "emily.white@email.com",
			"phone": "+44 7700123456",
			"linkedin": "https://linkedin.com/in/emilywhite"
		},
		"summary": "Mobile Developer with expertise in iOS and Android applications.",
		"experience": [
			{
			"position": "Mobile Developer",
			"company": "AppForge",
			"location": "London, UK",
			"period": "2019 - Present",
			"responsibilities": [
				"Developing and maintaining mobile applications",
				"Ensuring cross-platform compatibility",
				"Implementing UI/UX best practices"
			]
			}
		],
		"education": {
			"degree": "BSc in Computer Science",
			"institution": "University of Glasgow",
			"year_of_completion": 2017
		},
		"skills": ["Swift", "Kotlin", "Flutter", "React Native", "Firebase"],
		"languages": ["English (Fluent)", "Italian (Intermediate)"]
	},
	{
	"name": "Robert Wilson",
	"contact": {
		"email": "robert.wilson@email.com",
		"phone": "+44 7790011223",
		"linkedin": "https://linkedin.com/in/robertwilson"
	},
	"summary": "DevOps Engineer specializing in CI/CD and cloud infrastructure.",
	"experience": [
		{
		"position": "DevOps Engineer",
		"company": "CloudSync",
		"location": "Manchester, UK",
		"period": "2020 - Present",
		"responsibilities": [
			"Automating deployment pipelines",
			"Managing cloud infrastructure",
			"Implementing monitoring solutions"
		]
		}
	],
	"education": {
		"degree": "BSc in Information Systems",
		"institution": "University of Leeds",
		"year_of_completion": 2016
	},
	"skills": ["AWS", "Kubernetes", "Terraform", "Jenkins", "Docker"],
	"languages": ["English (Fluent)", "Dutch (Basic)"]
	},
	{
	"name": "David Clark",
	"contact": {
		"email": "david.clark@email.com",
		"phone": "+44 7780112233",
		"linkedin": "https://linkedin.com/in/davidclark"
	},
	"summary": "AI/ML Engineer specializing in deep learning and NLP applications.",
	"experience": [
		{
		"position": "AI Engineer",
		"company": "AI Solutions",
		"location": "London, UK",
		"period": "2019 - Present",
		"responsibilities": [
			"Developing AI models for natural language processing",
			"Optimizing machine learning algorithms",
			"Deploying AI solutions in production"
		]
		}
	],
	"education": {
		"degree": "MSc in Artificial Intelligence",
		"institution": "University of Cambridge",
		"year_of_completion": 2019
	},
	"skills": ["Python", "TensorFlow", "PyTorch", "NLP", "Data Science"],
	"languages": ["English (Fluent)", "Chinese (Intermediate)"]
	},
	{
	"name": "Emma Davis",
	"contact": {
		"email": "emma.davis@email.com",
		"phone": "+44 7712345678",
		"linkedin": "https://linkedin.com/in/emmadavis",
		"portfolio": "https://emmadavisdesign.com"
	},
	"summary": "UI/UX Designer with a passion for creating intuitive and engaging digital experiences.",
	"experience": [
		{
		"position": "Senior UI/UX Designer",
		"company": "Creative Labs",
		"location": "London, UK",
		"period": "2019 - Present",
		"responsibilities": [
			"Designing user-friendly web and mobile interfaces",
			"Conducting user research and usability testing",
			"Collaborating with developers to ensure seamless design implementation"
		]
		},
		{
		"position": "Junior UX Designer",
		"company": "WebVision",
		"location": "Manchester, UK",
		"period": "2017 - 2019",
		"responsibilities": [
			"Creating wireframes and prototypes",
			"Analyzing user behavior and feedback",
			"Developing user journey maps"
		]
		}
	],
	"education": {
		"degree": "BA in Graphic Design",
		"institution": "University of Arts London",
		"year_of_completion": 2017
	},
	"skills": ["Figma", "Sketch", "Adobe XD", "Prototyping", "User Research"],
	"languages": ["English (Fluent)", "French (Basic)"]
	},
	{
	"name": "James Miller",
	"contact": {
		"email": "james.miller@email.com",
		"phone": "+44 7798765432",
		"linkedin": "https://linkedin.com/in/jamesmiller",
		"portfolio": "https://jamesmillergraphics.com"
	},
	"summary": "Graphic Designer with a strong background in branding and visual storytelling.",
	"experience": [
		{
		"position": "Lead Graphic Designer",
		"company": "BrandWorks",
		"location": "London, UK",
		"period": "2020 - Present",
		"responsibilities": [
			"Developing brand identities for startups and enterprises",
			"Creating marketing materials and social media assets",
			"Leading a team of junior designers"
		]
		},
		{
		"position": "Graphic Designer",
		"company": "Creative Studio",
		"location": "Birmingham, UK",
		"period": "2016 - 2020",
		"responsibilities": [
			"Designing logos, brochures, and advertisements",
			"Working closely with marketing teams to create visual campaigns",
			"Ensuring consistency in brand messaging"
		]
		}
	],
	"education": {
		"degree": "BA in Visual Communication",
		"institution": "University of Birmingham",
		"year_of_completion": 2016
	},
	"skills": ["Adobe Photoshop", "Illustrator", "InDesign", "Branding", "Typography"],
	"languages": ["English (Native)", "Spanish (Intermediate)"]
	},
	{
	"name": "Olivia Roberts",
	"contact": {
		"email": "olivia.roberts@email.com",
		"phone": "+44 7786543210",
		"linkedin": "https://linkedin.com/in/oliviaroberts",
		"portfolio": "https://oliviarobertsdesigns.com"
	},
	"summary": "Motion Graphics Designer experienced in creating engaging animations for digital platforms.",
	"experience": [
		{
		"position": "Motion Graphics Artist",
		"company": "MediaPulse",
		"location": "Manchester, UK",
		"period": "2018 - Present",
		"responsibilities": [
			"Creating motion graphics for advertisements and social media",
			"Developing animated infographics and explainer videos",
			"Collaborating with video editors and marketing teams"
		]
		},
		{
		"position": "Junior Animator",
		"company": "Digital Creatives",
		"location": "Bristol, UK",
		"period": "2016 - 2018",
		"responsibilities": [
			"Designing animations for corporate clients",
			"Storyboarding and concept development",
			"Editing and refining animations based on feedback"
		]
		}
	],
	"education": {
		"degree": "BA in Animation & Motion Design",
		"institution": "University of Bristol",
		"year_of_completion": 2016
	},
	"skills": ["After Effects", "Cinema 4D", "Premiere Pro", "Storyboarding", "3D Animation"],
	"languages": ["English (Fluent)", "German (Basic)"]
	},
	{
	"name": "Sophia Williams",
	"contact": {
		"email": "sophia.williams@email.com",
		"phone": "+44 7712345678",
		"linkedin": "https://linkedin.com/in/sophiawilliams",
		"portfolio": "https://sophiawilliamsmarketing.com"
	},
	"summary": "Digital Marketing Specialist with a strong focus on SEO, content marketing, and PPC campaigns.",
	"experience": [
		{
		"position": "SEO & Content Marketing Manager",
		"company": "MarketingPro",
		"location": "London, UK",
		"period": "2020 - Present",
		"responsibilities": [
			"Developing and executing SEO strategies",
			"Managing content creation for blogs and social media",
			"Optimizing website performance to increase organic traffic"
		]
		},
		{
		"position": "Digital Marketing Analyst",
		"company": "GrowthHub",
		"location": "Manchester, UK",
		"period": "2017 - 2020",
		"responsibilities": [
			"Analyzing web traffic and user behavior",
			"Managing Google Ads and Facebook Ads campaigns",
			"Developing strategies for lead generation"
		]
		}
	],
	"education": {
		"degree": "BA in Marketing",
		"institution": "University of Manchester",
		"year_of_completion": 2017
	},
	"skills": ["SEO", "Google Ads", "Content Marketing", "Google Analytics", "Social Media Strategy"],
	"languages": ["English (Fluent)", "French (Intermediate)"]
	},
	{
	"name": "Daniel Carter",
	"contact": {
		"email": "daniel.carter@email.com",
		"phone": "+44 7798765432",
		"linkedin": "https://linkedin.com/in/danielcarter",
		"portfolio": "https://danielcartermarketing.com"
	},
	"summary": "Social Media Manager with expertise in brand storytelling and audience engagement.",
	"experience": [
		{
		"position": "Senior Social Media Manager",
		"company": "BrandBoost",
		"location": "London, UK",
		"period": "2019 - Present",
		"responsibilities": [
			"Developing and executing social media strategies",
			"Managing influencer partnerships",
			"Creating engaging content for Instagram, TikTok, and LinkedIn"
		]
		},
		{
		"position": "Social Media Coordinator",
		"company": "MediaWave",
		"location": "Bristol, UK",
		"period": "2016 - 2019",
		"responsibilities": [
			"Monitoring social media trends and engagement",
			"Creating reports on campaign performance",
			"Managing paid social media campaigns"
		]
		}
	],
	"education": {
		"degree": "BA in Communication & Media",
		"institution": "University of Bristol",
		"year_of_completion": 2016
	},
	"skills": ["Social Media Management", "Influencer Marketing", "Paid Ads", "Community Engagement", "Video Content Creation"],
	"languages": ["English (Native)", "Spanish (Basic)"]
	},
	{
	"name": "Isabella Martinez",
	"contact": {
		"email": "isabella.martinez@email.com",
		"phone": "+44 7786543210",
		"linkedin": "https://linkedin.com/in/isabellamartinez",
		"portfolio": "https://isabellamartinezmarketing.com"
	},
	"summary": "Performance Marketing Specialist focused on conversion optimization and growth marketing.",
	"experience": [
		{
		"position": "Performance Marketing Lead",
		"company": "Growth360",
		"location": "London, UK",
		"period": "2021 - Present",
		"responsibilities": [
			"Optimizing conversion rates for digital campaigns",
			"Managing PPC and display advertising",
			"A/B testing and customer journey analysis"
		]
		},
		{
		"position": "Digital Campaign Manager",
		"company": "AdTech Solutions",
		"location": "Manchester, UK",
		"period": "2017 - 2021",
		"responsibilities": [
			"Managing multi-channel ad campaigns",
			"Improving landing page performance",
			"Tracking and analyzing customer acquisition costs"
		]
		}
	],
	"education": {
		"degree": "MSc in Digital Marketing",
		"institution": "University of London",
		"year_of_completion": 2017
	},
	"skills": ["PPC", "Google Ads", "Meta Ads", "Conversion Rate Optimization", "A/B Testing"],
	"languages": ["English (Fluent)", "Portuguese (Intermediate)"]
	},
	{
	"name": "Liam Anderson",
	"contact": {
		"email": "liam.anderson@email.com",
		"phone": "+44 7712345678",
		"linkedin": "https://linkedin.com/in/liamanderson"
	},
	"summary": "Experienced Sales Executive specializing in digital solutions and SaaS sales.",
	"experience": [
		{
		"position": "Senior Sales Executive",
		"company": "TechSales Ltd.",
		"location": "London, UK",
		"period": "2020 - Present",
		"responsibilities": [
			"Generating leads and closing deals for SaaS products",
			"Developing sales strategies for digital transformation solutions",
			"Managing key accounts and building long-term client relationships"
		]
		},
		{
		"position": "Business Development Manager",
		"company": "Digital Growth Partners",
		"location": "Manchester, UK",
		"period": "2017 - 2020",
		"responsibilities": [
			"Expanding the client portfolio for digital services",
			"Negotiating contracts and proposals",
			"Providing insights on market trends and opportunities"
		]
		}
	],
	"education": {
		"degree": "BA in Business Administration",
		"institution": "University of Leeds",
		"year_of_completion": 2017
	},
	"skills": ["B2B Sales", "CRM (Salesforce, HubSpot)", "Negotiation", "Lead Generation", "SaaS Sales"],
	"languages": ["English (Fluent)", "German (Intermediate)"]
	},
	{
	"name": "Charlotte Evans",
	"contact": {
		"email": "charlotte.evans@email.com",
		"phone": "+44 7798765432",
		"linkedin": "https://linkedin.com/in/charlotteevans"
	},
	"summary": "Results-driven Account Manager with a strong background in digital advertising and client relations.",
	"experience": [
		{
		"position": "Account Manager",
		"company": "AdTech Solutions",
		"location": "London, UK",
		"period": "2019 - Present",
		"responsibilities": [
			"Managing digital advertising accounts for enterprise clients",
			"Developing strategic advertising campaigns",
			"Analyzing campaign performance and providing data-driven insights"
		]
		},
		{
		"position": "Sales Representative",
		"company": "MediaGrowth",
		"location": "Birmingham, UK",
		"period": "2016 - 2019",
		"responsibilities": [
			"Building relationships with potential advertisers",
			"Selling display and programmatic advertising solutions",
			"Providing client support and performance reports"
		]
		}
	],
	"education": {
		"degree": "BA in Marketing & Sales",
		"institution": "University of Birmingham",
		"year_of_completion": 2016
	},
	"skills": ["Client Relationship Management", "Digital Advertising", "Google Ads", "Sales Strategy", "Performance Analysis"],
	"languages": ["English (Native)", "Spanish (Basic)"]
	},
	{
	"name": "Ethan Harris",
	"contact": {
		"email": "ethan.harris@email.com",
		"phone": "+44 7786543210",
		"linkedin": "https://linkedin.com/in/ethanharris"
	},
	"summary": "Business Development Executive with expertise in digital products and online marketplaces.",
	"experience": [
		{
		"position": "Business Development Executive",
		"company": "E-Commerce Solutions Ltd.",
		"location": "London, UK",
		"period": "2021 - Present",
		"responsibilities": [
			"Identifying new business opportunities in the e-commerce sector",
			"Developing partnerships with online retailers and marketplaces",
			"Leading sales presentations and negotiations"
		]
		},
		{
		"position": "Sales Associate",
		"company": "Digital Commerce Inc.",
		"location": "Manchester, UK",
		"period": "2018 - 2021",
		"responsibilities": [
			"Managing inbound sales inquiries for digital services",
			"Assisting clients in optimizing their e-commerce presence",
			"Tracking key sales metrics and reporting trends"
		]
		}
	],
	"education": {
		"degree": "BA in Business & E-Commerce",
		"institution": "University of London",
		"year_of_completion": 2018
	},
	"skills": ["B2B Sales", "E-Commerce Strategy", "Partnership Development", "Negotiation", "Market Research"],
	"languages": ["English (Fluent)", "French (Intermediate)"]
	}
];

const contract = new ethers.Contract(CONTRACT_ADDRESS, contractABI, wallet);

let idCounter = 0;

module.exports = async function (fastify, opts)
{
	fastify.get('/add-persons', async (request, reply) => {
		try 
		{
			const transactions = [];
			
			for (const person of cvs) 
			{
				const id = idCounter++;
				const tx = await contract.addPerson(id, person.name, person.skills);
				await tx.wait();
				transactions.push({ id, txHash: tx.hash });
			}
	
			reply.send({ success: true, transactions });
		}
		catch (error)
		{
			request.log.error(error);
			reply.status(500).send({ success: false, error: error.message });
		}
	});

	fastify.get('/', async (request, reply) => 
	{
		try
		{
		const apiResponse = await axios.post(apiUrl, requestBody, {
			headers: { "Content-Type": "application/json" },
			timeout: 9000
		});

		if (!apiResponse || apiResponse.error || !apiResponse.data) 
		{
			throw new Error(`Request failed: ${apiResponse.error?.message || "Unknown error"}`);
		}

		const content = apiResponse.data.candidates[0].content.parts[0].text;

		if (!content) 
		{
			throw new Error('Error: Content not found');
		}
		
		countRequest += 1;
		console.log("countRequest", countRequest);

		return reply.send({ teamName: content });
		}
		catch (error)
		{
		console.error(error);
		return reply.status(500).send({ error: error.message || "Failed to generate team name" });
		}
	});


	fastify.get('/generate-team', async (request, reply) => {
		try {
			const people = await contract.getAllPeople();
			
			const participants = people.map(person => ({
				id: person.id.toString(),
				skills: person.skills
			}));

			const participantsString = JSON.stringify(participants);
			const requestBody = {
				contents: [{
					role: "user",
					parts: [
						{ text: "Create teams based on the following participants, have in consideration the skills of them and the number of participants, the teams should be as balanced as possible, to do that each team should have a variety of skills, and have more or less the same number of participants: " + participantsString + ". Also give each team a short name with pop culture references. The response should be an array of objects with the following structure: { name: string, members: string[] }. Return just the json object and nothing else, dont put the array inside of ```json ``` is very important, JUST THE ARRAY OF OBJECTS." }
					]
				}]
			};

			const apiResponse = await axios.post(apiUrl, requestBody, {
				headers: { "Content-Type": "application/json" },
				timeout: 9000
			});
	
			if (!apiResponse || apiResponse.error || !apiResponse.data) 
			{
				throw new Error(`Request failed: ${apiResponse.error?.message || "Unknown error"}`);
			}
	
			const content = apiResponse.data.candidates[0].content.parts[0].text;
	
			if (!content) 
			{
				throw new Error('Error: Content not found');
			}

			const teams = JSON.parse(apiResponse.data.candidates[0].content.parts[0].text.replace(/\n/g, '').trim());

			for (const team of teams) {
				const memberIds = team.members.map(id => parseInt(id)); // Convert IDs to uint256[]
				const tx = await contract.createTeam(team.name, memberIds);
				console.log(`Creating team: ${team.name} with members ${memberIds}`);
				await tx.wait();
			}
	
			reply.send({ success: true, teams });
		} catch (error) {
			request.log.error(error);
			reply.status(500).send({ success: false, error: error.message });
		}
	});
}