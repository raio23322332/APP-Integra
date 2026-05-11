import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

IconData mapCategoryIcon(String iconName) {
  switch (iconName) {
    case 'Trash2':
      return LucideIcons.trash2;

    case 'Pen':
      return LucideIcons.penLine;

    case 'ArrowLeft':
      return LucideIcons.arrowLeft;

    case 'Sprout':
      return LucideIcons.sprout;

    case 'CirclePlus':
      return LucideIcons.circlePlus;

    case 'HeartHandshake':
      return LucideIcons.handshake;

    case 'Microscope':
      return LucideIcons.microscope;

    case 'Megaphone':
      return LucideIcons.megaphone;

    case 'Palette':
      return LucideIcons.palette;

    case 'GraduationCap':
      return LucideIcons.graduationCap;

    case 'Landmark':
      return LucideIcons.landmark;

    case 'Building':
      return LucideIcons.building;

    case 'Building2':
      return LucideIcons.building2;

    case 'Factory':
      return LucideIcons.factory;

    case 'Wrench':
      return LucideIcons.wrench;

    case 'Leaf':
      return LucideIcons.leaf;

    case 'ShieldCheck':
      return LucideIcons.shieldCheck;

    case 'Droplets':
      return LucideIcons.droplets;

    case 'HeartPulse':
      return LucideIcons.heartPulse;

    case 'Shield':
      return LucideIcons.shield;

    case 'Lock':
      return LucideIcons.lock;

    case 'Scale':
      return LucideIcons.scale;

    case 'Briefcase':
      return LucideIcons.briefcase;

    // ========== ÍCONES ADICIONAIS DO PROJETO ==========
    // Natureza e Meio Ambiente
    case 'TreePine':
      return LucideIcons.treePine;
    case 'Flower':
      return LucideIcons.flower;
    case 'Mountain':
      return LucideIcons.mountain;
    case 'TreeDeciduous':
      return LucideIcons.treeDeciduous;

    // Saúde e Bem-estar
    case 'Stethoscope':
      return LucideIcons.stethoscope;
    case 'Activity':
      return LucideIcons.activity;
    case 'Brain':
      return LucideIcons.brain;
    case 'Heart':
      return LucideIcons.heart;

    // Ciência e Educação
    case 'BookOpen':
      return LucideIcons.bookOpen;
    case 'Atom':
      return LucideIcons.atom;
    case 'Beaker':
      return LucideIcons.beaker;
    case 'Calculator':
      return LucideIcons.calculator;

    // Comunicação e Mídia
    case 'Share2':
      return LucideIcons.share2;
    case 'MessageCircle':
      return LucideIcons.messageCircle;
    case 'Phone':
      return LucideIcons.phone;
    case 'Mail':
      return LucideIcons.mail;
    case 'Video':
      return LucideIcons.video;

    // Arte e Cultura
    case 'Brush':
      return LucideIcons.brush;
    case 'Drama':
      return LucideIcons.drama;
    case 'Music':
      return LucideIcons.music;
    case 'Camera':
      return LucideIcons.camera;
    case 'Film':
      return LucideIcons.film;

    // Negócios e Finanças
    case 'Store':
      return LucideIcons.store;
    case 'DollarSign':
      return LucideIcons.dollarSign;
    case 'CreditCard':
      return LucideIcons.creditCard;
    case 'TrendingUp':
      return LucideIcons.trendingUp;

    // Tecnologia
    case 'Monitor':
      return LucideIcons.monitor;
    case 'Cpu':
      return LucideIcons.cpu;
    case 'Smartphone':
      return LucideIcons.smartphone;
    case 'Database':
      return LucideIcons.database;
    case 'Code':
      return LucideIcons.code;
    case 'Wifi':
      return LucideIcons.wifi;
    case 'Server':
      return LucideIcons.server;

    // Transporte
    case 'Car':
      return LucideIcons.car;
    case 'Bike':
      return LucideIcons.bike;
    case 'Plane':
      return LucideIcons.plane;
    case 'Ship':
      return LucideIcons.ship;
    // Transporte adicional
    case 'Bus':
      return LucideIcons.bus;
    case 'Train':
      return LucideIcons.truck;

    // Ferramentas e Utilitários
    case 'Hammer':
      return LucideIcons.hammer;
    case 'Package':
      return LucideIcons.package;
    case 'Settings':
      return LucideIcons.settings;
    case 'Tool':
      return LucideIcons.wrench;

    // Segurança e Legal
    case 'Gavel':
      return LucideIcons.gavel;
    case 'Key':
      return LucideIcons.key;

    // Alimentos e Bebidas
    case 'Coffee':
      return LucideIcons.coffee;
    case 'Utensils':
      return LucideIcons.utensils;
    case 'Pizza':
      return LucideIcons.pizza;
    case 'Wine':
      return LucideIcons.wine;
    case 'Apple':
      return LucideIcons.apple;
    case 'ChefHat':
      return LucideIcons.chefHat;

    // Esportes e Lazer
    case 'Trophy':
      return LucideIcons.trophy;
    case 'Gamepad2':
      return LucideIcons.gamepad2;
    case 'Dumbbell':
      return LucideIcons.dumbbell;
    case 'Tennis':
      return LucideIcons.circle;
    case 'Football':
      return LucideIcons.circle;
    case 'Swimmer':
      return LucideIcons.user;

    // Clima
    case 'Cloud':
      return LucideIcons.cloud;
    case 'Sun':
      return LucideIcons.sun;
    case 'Umbrella':
      return LucideIcons.umbrella;
    case 'Thermometer':
      return LucideIcons.thermometer;
    case 'Wind':
      return LucideIcons.wind;

    // Governo e Instituições
    case 'Hospital':
      return LucideIcons.hospital;
    case 'School':
      return LucideIcons.school;
    case 'Banknote':
      return LucideIcons.banknote;
    case 'Globe':
      return LucideIcons.globe;

    // Pessoas e Sociedade
    case 'Smile':
      return LucideIcons.smile;
    case 'Baby':
      return LucideIcons.baby;
    case 'Users':
      return LucideIcons.users;
    case 'UserPlus':
      return LucideIcons.userPlus;
    case 'Handshake':
      return LucideIcons.handshake;

    // ========== HEROICONS ESPECÍFICOS ==========
    case 'HomeIcon':
      return LucideIcons.house;
    case 'GlobeAltIcon':
      return LucideIcons.globe;

    // ========== ÍCONE PARA SERVIÇOS GENÉRICOS ==========
    case 'MiscellaneousServices':
      return LucideIcons.wrench;
    
    case 'search':
      return LucideIcons.search;

    case 'Home':
      return LucideIcons.house;

    default:
      // Log para debug de ícones não mapeados
      debugPrint('Ícone não mapeado: $iconName');
      return LucideIcons.circle; // fallback
  }
}
